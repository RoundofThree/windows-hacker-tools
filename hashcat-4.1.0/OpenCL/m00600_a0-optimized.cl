/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#define NEW_SIMD_CODE

#include "inc_vendor.cl"
#include "inc_hash_constants.h"
#include "inc_hash_functions.cl"
#include "inc_types.cl"
#include "inc_common.cl"
#include "inc_rp_optimized.h"
#include "inc_rp_optimized.cl"
#include "inc_simd.cl"

#define BLAKE2B_FINAL   1
#define BLAKE2B_UPDATE  0

#define BLAKE2B_G(r,i,a,b,c,d)                \
  do {                                        \
    a = a + b + m[blake2b_sigma[r][2*i+0]];   \
    d = rotr64 (d ^ a, 32);                   \
    c = c + d;                                \
    b = rotr64 (b ^ c, 24);                   \
    a = a + b + m[blake2b_sigma[r][2*i+1]];   \
    d = rotr64 (d ^ a, 16);                   \
    c = c + d;                                \
    b = rotr64 (b ^ c, 63);                   \
  } while(0)

#define BLAKE2B_ROUND(r)                     \
  do {                                       \
    BLAKE2B_G (r,0,v[ 0],v[ 4],v[ 8],v[12]); \
    BLAKE2B_G (r,1,v[ 1],v[ 5],v[ 9],v[13]); \
    BLAKE2B_G (r,2,v[ 2],v[ 6],v[10],v[14]); \
    BLAKE2B_G (r,3,v[ 3],v[ 7],v[11],v[15]); \
    BLAKE2B_G (r,4,v[ 0],v[ 5],v[10],v[15]); \
    BLAKE2B_G (r,5,v[ 1],v[ 6],v[11],v[12]); \
    BLAKE2B_G (r,6,v[ 2],v[ 7],v[ 8],v[13]); \
    BLAKE2B_G (r,7,v[ 3],v[ 4],v[ 9],v[14]); \
} while(0)

DECLSPEC void blake2b_transform (u64x h[8], u64x t[2], u64x f[2], u64x m[16], u64x v[16], const u32x w0[4], const u32x w1[4], const u32x w2[4], const u32x w3[4], const u32x out_len, const u8 isFinal)
{
  if (isFinal)
    f[0] = -1;

  t[0] += hl32_to_64 (0, out_len);

  m[ 0] = hl32_to_64 (w0[1], w0[0]);
  m[ 1] = hl32_to_64 (w0[3], w0[2]);
  m[ 2] = hl32_to_64 (w1[1], w1[0]);
  m[ 3] = hl32_to_64 (w1[3], w1[2]);
  m[ 4] = hl32_to_64 (w2[1], w2[0]);
  m[ 5] = hl32_to_64 (w2[3], w2[2]);
  m[ 6] = hl32_to_64 (w3[1], w3[0]);
  m[ 7] = hl32_to_64 (w3[3], w3[2]);
  m[ 8] = 0;
  m[ 9] = 0;
  m[10] = 0;
  m[11] = 0;
  m[12] = 0;
  m[13] = 0;
  m[14] = 0;
  m[15] = 0;

  v[ 0] = h[0];
  v[ 1] = h[1];
  v[ 2] = h[2];
  v[ 3] = h[3];
  v[ 4] = h[4];
  v[ 5] = h[5];
  v[ 6] = h[6];
  v[ 7] = h[7];
  v[ 8] = BLAKE2B_IV_00;
  v[ 9] = BLAKE2B_IV_01;
  v[10] = BLAKE2B_IV_02;
  v[11] = BLAKE2B_IV_03;
  v[12] = BLAKE2B_IV_04 ^ t[0];
  v[13] = BLAKE2B_IV_05 ^ t[1];
  v[14] = BLAKE2B_IV_06 ^ f[0];
  v[15] = BLAKE2B_IV_07 ^ f[1];

  const int blake2b_sigma[12][16] =
  {
    {  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15 } ,
    { 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3 } ,
    { 11,  8, 12,  0,  5,  2, 15, 13, 10, 14,  3,  6,  7,  1,  9,  4 } ,
    {  7,  9,  3,  1, 13, 12, 11, 14,  2,  6,  5, 10,  4,  0, 15,  8 } ,
    {  9,  0,  5,  7,  2,  4, 10, 15, 14,  1, 11, 12,  6,  8,  3, 13 } ,
    {  2, 12,  6, 10,  0, 11,  8,  3,  4, 13,  7,  5, 15, 14,  1,  9 } ,
    { 12,  5,  1, 15, 14, 13,  4, 10,  0,  7,  6,  3,  9,  2,  8, 11 } ,
    { 13, 11,  7, 14, 12,  1,  3,  9,  5,  0, 15,  4,  8,  6,  2, 10 } ,
    {  6, 15, 14,  9, 11,  3,  0,  8, 12,  2, 13,  7,  1,  4, 10,  5 } ,
    { 10,  2,  8,  4,  7,  6,  1,  5, 15, 11,  9, 14,  3, 12, 13 , 0 } ,
    {  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15 } ,
    { 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3 }
  };

  BLAKE2B_ROUND ( 0);
  BLAKE2B_ROUND ( 1);
  BLAKE2B_ROUND ( 2);
  BLAKE2B_ROUND ( 3);
  BLAKE2B_ROUND ( 4);
  BLAKE2B_ROUND ( 5);
  BLAKE2B_ROUND ( 6);
  BLAKE2B_ROUND ( 7);
  BLAKE2B_ROUND ( 8);
  BLAKE2B_ROUND ( 9);
  BLAKE2B_ROUND (10);
  BLAKE2B_ROUND (11);

  h[0] = h[0] ^ v[0] ^ v[ 8];
  h[1] = h[1] ^ v[1] ^ v[ 9];
  h[2] = h[2] ^ v[2] ^ v[10];
  h[3] = h[3] ^ v[3] ^ v[11];
  h[4] = h[4] ^ v[4] ^ v[12];
  h[5] = h[5] ^ v[5] ^ v[13];
  h[6] = h[6] ^ v[6] ^ v[14];
  h[7] = h[7] ^ v[7] ^ v[15];
}

__kernel void m00600_m04 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const blake2_t *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);

  u32 pw_buf0[4];
  u32 pw_buf1[4];

  pw_buf0[0] = pws[gid].i[0];
  pw_buf0[1] = pws[gid].i[1];
  pw_buf0[2] = pws[gid].i[2];
  pw_buf0[3] = pws[gid].i[3];
  pw_buf1[0] = pws[gid].i[4];
  pw_buf1[1] = pws[gid].i[5];
  pw_buf1[2] = pws[gid].i[6];
  pw_buf1[3] = pws[gid].i[7];

  const u32 pw_len = pws[gid].pw_len;

  u64 tmp_h[8];
  u64 tmp_t[2];
  u64 tmp_f[2];

  tmp_h[0] = esalt_bufs[digests_offset].h[0];
  tmp_h[1] = esalt_bufs[digests_offset].h[1];
  tmp_h[2] = esalt_bufs[digests_offset].h[2];
  tmp_h[3] = esalt_bufs[digests_offset].h[3];
  tmp_h[4] = esalt_bufs[digests_offset].h[4];
  tmp_h[5] = esalt_bufs[digests_offset].h[5];
  tmp_h[6] = esalt_bufs[digests_offset].h[6];
  tmp_h[7] = esalt_bufs[digests_offset].h[7];

  tmp_t[0] = esalt_bufs[digests_offset].t[0];
  tmp_t[1] = esalt_bufs[digests_offset].t[1];
  tmp_f[0] = esalt_bufs[digests_offset].f[0];
  tmp_f[1] = esalt_bufs[digests_offset].f[1];

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    u32x w0[4] = { 0 };
    u32x w1[4] = { 0 };
    u32x w2[4] = { 0 };
    u32x w3[4] = { 0 };

    const u32x out_len = apply_rules_vect(pw_buf0, pw_buf1, pw_len, rules_buf, il_pos, w0, w1);

    u64x digest[8];

    u64x m[16];
    u64x v[16];

    u64x h[8];
    u64x t[2];
    u64x f[2];

    h[0] = tmp_h[0];
    h[1] = tmp_h[1];
    h[2] = tmp_h[2];
    h[3] = tmp_h[3];
    h[4] = tmp_h[4];
    h[5] = tmp_h[5];
    h[6] = tmp_h[6];
    h[7] = tmp_h[7];

    t[0] = tmp_t[0];
    t[1] = tmp_t[1];
    f[0] = tmp_f[0];
    f[1] = tmp_f[1];

    blake2b_transform(h, t, f, m, v, w0, w1, w2, w3, out_len, BLAKE2B_FINAL);

    digest[0] = h[0];
    digest[1] = h[1];
    digest[2] = h[2];
    digest[3] = h[3];
    digest[4] = h[4];
    digest[5] = h[5];
    digest[6] = h[6];
    digest[7] = h[7];

    const u32x r0 = h32_from_64(digest[0]);
    const u32x r1 = l32_from_64(digest[0]);
    const u32x r2 = h32_from_64(digest[1]);
    const u32x r3 = l32_from_64(digest[1]);

    COMPARE_M_SIMD(r0, r1, r2, r3);
  }
}

__kernel void m00600_m08 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const blake2_t *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m00600_m16 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const blake2_t *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m00600_s04 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const blake2_t *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 pw_buf0[4];
  u32 pw_buf1[4];

  pw_buf0[0] = pws[gid].i[0];
  pw_buf0[1] = pws[gid].i[1];
  pw_buf0[2] = pws[gid].i[2];
  pw_buf0[3] = pws[gid].i[3];
  pw_buf1[0] = pws[gid].i[4];
  pw_buf1[1] = pws[gid].i[5];
  pw_buf1[2] = pws[gid].i[6];
  pw_buf1[3] = pws[gid].i[7];

  const u32 pw_len = pws[gid].pw_len;

  u64 tmp_h[8];
  u64 tmp_t[2];
  u64 tmp_f[2];

  tmp_h[0] = esalt_bufs[digests_offset].h[0];
  tmp_h[1] = esalt_bufs[digests_offset].h[1];
  tmp_h[2] = esalt_bufs[digests_offset].h[2];
  tmp_h[3] = esalt_bufs[digests_offset].h[3];
  tmp_h[4] = esalt_bufs[digests_offset].h[4];
  tmp_h[5] = esalt_bufs[digests_offset].h[5];
  tmp_h[6] = esalt_bufs[digests_offset].h[6];
  tmp_h[7] = esalt_bufs[digests_offset].h[7];

  tmp_t[0] = esalt_bufs[digests_offset].t[0];
  tmp_t[1] = esalt_bufs[digests_offset].t[1];
  tmp_f[0] = esalt_bufs[digests_offset].f[0];
  tmp_f[1] = esalt_bufs[digests_offset].f[1];

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[digests_offset].digest_buf[DGST_R0],
    digests_buf[digests_offset].digest_buf[DGST_R1],
    digests_buf[digests_offset].digest_buf[DGST_R2],
    digests_buf[digests_offset].digest_buf[DGST_R3]
  };

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    u32x w0[4] = { 0 };
    u32x w1[4] = { 0 };
    u32x w2[4] = { 0 };
    u32x w3[4] = { 0 };

    const u32x out_len = apply_rules_vect(pw_buf0, pw_buf1, pw_len, rules_buf, il_pos, w0, w1);

    u64x digest[8];
    u64x m[16];
    u64x v[16];

    u64x h[8];
    u64x t[2];
    u64x f[2];

    h[0] = tmp_h[0];
    h[1] = tmp_h[1];
    h[2] = tmp_h[2];
    h[3] = tmp_h[3];
    h[4] = tmp_h[4];
    h[5] = tmp_h[5];
    h[6] = tmp_h[6];
    h[7] = tmp_h[7];

    t[0] = tmp_t[0];
    t[1] = tmp_t[1];
    f[0] = tmp_f[0];
    f[1] = tmp_f[1];

    blake2b_transform(h, t, f, m, v, w0, w1, w2, w3, out_len, BLAKE2B_FINAL);

    digest[0] = h[0];
    digest[1] = h[1];
    digest[2] = h[2];
    digest[3] = h[3];
    digest[4] = h[4];
    digest[5] = h[5];
    digest[6] = h[6];
    digest[7] = h[7];

    const u32x r0 = h32_from_64(digest[0]);
    const u32x r1 = l32_from_64(digest[0]);
    const u32x r2 = h32_from_64(digest[1]);
    const u32x r3 = l32_from_64(digest[1]);

    COMPARE_S_SIMD(r0, r1, r2, r3);
  }
}

__kernel void m00600_s08 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const blake2_t *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m00600_s16 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const blake2_t *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}
