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
#include "inc_simd.cl"
#include "inc_hash_sha512.cl"

DECLSPEC void sha512_transform_transport_vector (const u64x w0[4], const u64x w1[4], const u64x w2[4], const u64x w3[4], u64x digest[8])
{
  u32x t0[4];
  u32x t1[4];
  u32x t2[4];
  u32x t3[4];
  u32x t4[4];
  u32x t5[4];
  u32x t6[4];
  u32x t7[4];

  t0[0] = h32_from_64 (w0[0]);
  t0[1] = l32_from_64 (w0[0]);
  t0[2] = h32_from_64 (w0[1]);
  t0[3] = l32_from_64 (w0[1]);
  t1[0] = h32_from_64 (w0[2]);
  t1[1] = l32_from_64 (w0[2]);
  t1[2] = h32_from_64 (w0[3]);
  t1[3] = l32_from_64 (w0[3]);
  t2[0] = h32_from_64 (w1[0]);
  t2[1] = l32_from_64 (w1[0]);
  t2[2] = h32_from_64 (w1[1]);
  t2[3] = l32_from_64 (w1[1]);
  t3[0] = h32_from_64 (w1[2]);
  t3[1] = l32_from_64 (w1[2]);
  t3[2] = h32_from_64 (w1[3]);
  t3[3] = l32_from_64 (w1[3]);
  t4[0] = h32_from_64 (w2[0]);
  t4[1] = l32_from_64 (w2[0]);
  t4[2] = h32_from_64 (w2[1]);
  t4[3] = l32_from_64 (w2[1]);
  t5[0] = h32_from_64 (w2[2]);
  t5[1] = l32_from_64 (w2[2]);
  t5[2] = h32_from_64 (w2[3]);
  t5[3] = l32_from_64 (w2[3]);
  t6[0] = h32_from_64 (w3[0]);
  t6[1] = l32_from_64 (w3[0]);
  t6[2] = h32_from_64 (w3[1]);
  t6[3] = l32_from_64 (w3[1]);
  t7[0] = h32_from_64 (w3[2]);
  t7[1] = l32_from_64 (w3[2]);
  t7[2] = h32_from_64 (w3[3]);
  t7[3] = l32_from_64 (w3[3]);

  sha512_transform_vector (t0, t1, t2, t3, t4, t5, t6, t7, digest);
}

DECLSPEC void hmac_sha512_pad (u32x w0[4], u32x w1[4], u32x w2[4], u32x w3[4], u64x ipad[8], u64x opad[8])
{
  u64x w0_t[4];
  u64x w1_t[4];
  u64x w2_t[4];
  u64x w3_t[4];

  w0_t[0] = hl32_to_64 (w0[0], w0[1]) ^ (u64x) 0x3636363636363636;
  w0_t[1] = hl32_to_64 (w0[2], w0[3]) ^ (u64x) 0x3636363636363636;
  w0_t[2] = hl32_to_64 (w1[0], w1[1]) ^ (u64x) 0x3636363636363636;
  w0_t[3] = hl32_to_64 (w1[2], w1[3]) ^ (u64x) 0x3636363636363636;
  w1_t[0] = hl32_to_64 (w2[0], w2[1]) ^ (u64x) 0x3636363636363636;
  w1_t[1] = hl32_to_64 (w2[2], w2[3]) ^ (u64x) 0x3636363636363636;
  w1_t[2] = hl32_to_64 (w3[0], w3[1]) ^ (u64x) 0x3636363636363636;
  w1_t[3] = hl32_to_64 (w3[2], w3[3]) ^ (u64x) 0x3636363636363636;
  w2_t[0] =                             (u64x) 0x3636363636363636;
  w2_t[1] =                             (u64x) 0x3636363636363636;
  w2_t[2] =                             (u64x) 0x3636363636363636;
  w2_t[3] =                             (u64x) 0x3636363636363636;
  w3_t[0] =                             (u64x) 0x3636363636363636;
  w3_t[1] =                             (u64x) 0x3636363636363636;
  w3_t[2] =                             (u64x) 0x3636363636363636;
  w3_t[3] =                             (u64x) 0x3636363636363636;

  ipad[0] = SHA512M_A;
  ipad[1] = SHA512M_B;
  ipad[2] = SHA512M_C;
  ipad[3] = SHA512M_D;
  ipad[4] = SHA512M_E;
  ipad[5] = SHA512M_F;
  ipad[6] = SHA512M_G;
  ipad[7] = SHA512M_H;

  sha512_transform_transport_vector (w0_t, w1_t, w2_t, w3_t, ipad);

  w0_t[0] = hl32_to_64 (w0[0], w0[1]) ^ (u64x) 0x5c5c5c5c5c5c5c5c;
  w0_t[1] = hl32_to_64 (w0[2], w0[3]) ^ (u64x) 0x5c5c5c5c5c5c5c5c;
  w0_t[2] = hl32_to_64 (w1[0], w1[1]) ^ (u64x) 0x5c5c5c5c5c5c5c5c;
  w0_t[3] = hl32_to_64 (w1[2], w1[3]) ^ (u64x) 0x5c5c5c5c5c5c5c5c;
  w1_t[0] = hl32_to_64 (w2[0], w2[1]) ^ (u64x) 0x5c5c5c5c5c5c5c5c;
  w1_t[1] = hl32_to_64 (w2[2], w2[3]) ^ (u64x) 0x5c5c5c5c5c5c5c5c;
  w1_t[2] = hl32_to_64 (w3[0], w3[1]) ^ (u64x) 0x5c5c5c5c5c5c5c5c;
  w1_t[3] = hl32_to_64 (w3[2], w3[3]) ^ (u64x) 0x5c5c5c5c5c5c5c5c;
  w2_t[0] =                             (u64x) 0x5c5c5c5c5c5c5c5c;
  w2_t[1] =                             (u64x) 0x5c5c5c5c5c5c5c5c;
  w2_t[2] =                             (u64x) 0x5c5c5c5c5c5c5c5c;
  w2_t[3] =                             (u64x) 0x5c5c5c5c5c5c5c5c;
  w3_t[0] =                             (u64x) 0x5c5c5c5c5c5c5c5c;
  w3_t[1] =                             (u64x) 0x5c5c5c5c5c5c5c5c;
  w3_t[2] =                             (u64x) 0x5c5c5c5c5c5c5c5c;
  w3_t[3] =                             (u64x) 0x5c5c5c5c5c5c5c5c;

  opad[0] = SHA512M_A;
  opad[1] = SHA512M_B;
  opad[2] = SHA512M_C;
  opad[3] = SHA512M_D;
  opad[4] = SHA512M_E;
  opad[5] = SHA512M_F;
  opad[6] = SHA512M_G;
  opad[7] = SHA512M_H;

  sha512_transform_transport_vector (w0_t, w1_t, w2_t, w3_t, opad);
}

DECLSPEC void hmac_sha512_run (u32x w0[4], u32x w1[4], u32x w2[4], u32x w3[4], u64x ipad[8], u64x opad[8], u64x digest[8])
{
  u64x w0_t[4];
  u64x w1_t[4];
  u64x w2_t[4];
  u64x w3_t[4];

  w0_t[0] = hl32_to_64 (w0[0], w0[1]);
  w0_t[1] = hl32_to_64 (w0[2], w0[3]);
  w0_t[2] = hl32_to_64 (w1[0], w1[1]);
  w0_t[3] = hl32_to_64 (w1[2], w1[3]);
  w1_t[0] = hl32_to_64 (w2[0], w2[1]);
  w1_t[1] = hl32_to_64 (w2[2], w2[3]);
  w1_t[2] = hl32_to_64 (w3[0], w3[1]);
  w1_t[3] = 0;
  w2_t[0] = 0;
  w2_t[1] = 0;
  w2_t[2] = 0;
  w2_t[3] = 0;
  w3_t[0] = 0;
  w3_t[1] = 0;
  w3_t[2] = 0;
  w3_t[3] = hl32_to_64 (w3[2], w3[3]);

  digest[0] = ipad[0];
  digest[1] = ipad[1];
  digest[2] = ipad[2];
  digest[3] = ipad[3];
  digest[4] = ipad[4];
  digest[5] = ipad[5];
  digest[6] = ipad[6];
  digest[7] = ipad[7];

  sha512_transform_transport_vector (w0_t, w1_t, w2_t, w3_t, digest);

  w0_t[0] = digest[0];
  w0_t[1] = digest[1];
  w0_t[2] = digest[2];
  w0_t[3] = digest[3];
  w1_t[0] = digest[4];
  w1_t[1] = digest[5];
  w1_t[2] = digest[6];
  w1_t[3] = digest[7];
  w2_t[0] = 0x8000000000000000;
  w2_t[1] = 0;
  w2_t[2] = 0;
  w2_t[3] = 0;
  w3_t[0] = 0;
  w3_t[1] = 0;
  w3_t[2] = 0;
  w3_t[3] = (128 + 64) * 8;

  digest[0] = opad[0];
  digest[1] = opad[1];
  digest[2] = opad[2];
  digest[3] = opad[3];
  digest[4] = opad[4];
  digest[5] = opad[5];
  digest[6] = opad[6];
  digest[7] = opad[7];

  sha512_transform_transport_vector (w0_t, w1_t, w2_t, w3_t, digest);
}

DECLSPEC void m01760m (u32 w0[4], u32 w1[4], u32 w2[4], u32 w3[4], const u32 pw_len, __global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esal_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);

  /**
   * salt
   */

  u32 salt_buf0[4];
  u32 salt_buf1[4];
  u32 salt_buf2[4];
  u32 salt_buf3[4];

  salt_buf0[0] = swap32_S (salt_bufs[salt_pos].salt_buf[ 0]);
  salt_buf0[1] = swap32_S (salt_bufs[salt_pos].salt_buf[ 1]);
  salt_buf0[2] = swap32_S (salt_bufs[salt_pos].salt_buf[ 2]);
  salt_buf0[3] = swap32_S (salt_bufs[salt_pos].salt_buf[ 3]);
  salt_buf1[0] = swap32_S (salt_bufs[salt_pos].salt_buf[ 4]);
  salt_buf1[1] = swap32_S (salt_bufs[salt_pos].salt_buf[ 5]);
  salt_buf1[2] = swap32_S (salt_bufs[salt_pos].salt_buf[ 6]);
  salt_buf1[3] = swap32_S (salt_bufs[salt_pos].salt_buf[ 7]);
  salt_buf2[0] = swap32_S (salt_bufs[salt_pos].salt_buf[ 8]);
  salt_buf2[1] = swap32_S (salt_bufs[salt_pos].salt_buf[ 9]);
  salt_buf2[2] = swap32_S (salt_bufs[salt_pos].salt_buf[10]);
  salt_buf2[3] = swap32_S (salt_bufs[salt_pos].salt_buf[11]);
  salt_buf3[0] = swap32_S (salt_bufs[salt_pos].salt_buf[12]);
  salt_buf3[1] = swap32_S (salt_bufs[salt_pos].salt_buf[13]);
  salt_buf3[2] = swap32_S (salt_bufs[salt_pos].salt_buf[14]);
  salt_buf3[3] = swap32_S (salt_bufs[salt_pos].salt_buf[15]);

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  /**
   * pads
   */

  u32x w0_t[4];
  u32x w1_t[4];
  u32x w2_t[4];
  u32x w3_t[4];

  w0_t[0] = salt_buf0[0];
  w0_t[1] = salt_buf0[1];
  w0_t[2] = salt_buf0[2];
  w0_t[3] = salt_buf0[3];
  w1_t[0] = salt_buf1[0];
  w1_t[1] = salt_buf1[1];
  w1_t[2] = salt_buf1[2];
  w1_t[3] = salt_buf1[3];
  w2_t[0] = salt_buf2[0];
  w2_t[1] = salt_buf2[1];
  w2_t[2] = salt_buf2[2];
  w2_t[3] = salt_buf2[3];
  w3_t[0] = salt_buf3[0];
  w3_t[1] = salt_buf3[1];
  w3_t[2] = salt_buf3[2];
  w3_t[3] = salt_buf3[3];

  u64x ipad[8];
  u64x opad[8];

  hmac_sha512_pad (w0_t, w1_t, w2_t, w3_t, ipad, opad);

  /**
   * loop
   */

  u32 w0l = w0[0];

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x w0r = ix_create_bft (bfs_buf, il_pos);

    const u32x w0lr = w0l | w0r;

    w0_t[0] = w0lr;
    w0_t[1] = w0[1];
    w0_t[2] = w0[2];
    w0_t[3] = w0[3];
    w1_t[0] = w1[0];
    w1_t[1] = w1[1];
    w1_t[2] = w1[2];
    w1_t[3] = w1[3];
    w2_t[0] = w2[0];
    w2_t[1] = w2[1];
    w2_t[2] = w2[2];
    w2_t[3] = w2[3];
    w3_t[0] = w3[0];
    w3_t[1] = w3[1];
    w3_t[2] = 0;
    w3_t[3] = (128 + pw_len) * 8;

    u64x digest[8];

    hmac_sha512_run (w0_t, w1_t, w2_t, w3_t, ipad, opad, digest);

    const u32x r0 = l32_from_64 (digest[7]);
    const u32x r1 = h32_from_64 (digest[7]);
    const u32x r2 = l32_from_64 (digest[3]);
    const u32x r3 = h32_from_64 (digest[3]);

    COMPARE_M_SIMD (r0, r1, r2, r3);
  }
}

DECLSPEC void m01760s (u32 w0[4], u32 w1[4], u32 w2[4], u32 w3[4], const u32 pw_len, __global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);

  /**
   * salt
   */

  u32 salt_buf0[4];
  u32 salt_buf1[4];
  u32 salt_buf2[4];
  u32 salt_buf3[4];

  salt_buf0[0] = swap32_S (salt_bufs[salt_pos].salt_buf[ 0]);
  salt_buf0[1] = swap32_S (salt_bufs[salt_pos].salt_buf[ 1]);
  salt_buf0[2] = swap32_S (salt_bufs[salt_pos].salt_buf[ 2]);
  salt_buf0[3] = swap32_S (salt_bufs[salt_pos].salt_buf[ 3]);
  salt_buf1[0] = swap32_S (salt_bufs[salt_pos].salt_buf[ 4]);
  salt_buf1[1] = swap32_S (salt_bufs[salt_pos].salt_buf[ 5]);
  salt_buf1[2] = swap32_S (salt_bufs[salt_pos].salt_buf[ 6]);
  salt_buf1[3] = swap32_S (salt_bufs[salt_pos].salt_buf[ 7]);
  salt_buf2[0] = swap32_S (salt_bufs[salt_pos].salt_buf[ 8]);
  salt_buf2[1] = swap32_S (salt_bufs[salt_pos].salt_buf[ 9]);
  salt_buf2[2] = swap32_S (salt_bufs[salt_pos].salt_buf[10]);
  salt_buf2[3] = swap32_S (salt_bufs[salt_pos].salt_buf[11]);
  salt_buf3[0] = swap32_S (salt_bufs[salt_pos].salt_buf[12]);
  salt_buf3[1] = swap32_S (salt_bufs[salt_pos].salt_buf[13]);
  salt_buf3[2] = swap32_S (salt_bufs[salt_pos].salt_buf[14]);
  salt_buf3[3] = swap32_S (salt_bufs[salt_pos].salt_buf[15]);

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  /**
   * pads
   */

  u32x w0_t[4];
  u32x w1_t[4];
  u32x w2_t[4];
  u32x w3_t[4];

  w0_t[0] = salt_buf0[0];
  w0_t[1] = salt_buf0[1];
  w0_t[2] = salt_buf0[2];
  w0_t[3] = salt_buf0[3];
  w1_t[0] = salt_buf1[0];
  w1_t[1] = salt_buf1[1];
  w1_t[2] = salt_buf1[2];
  w1_t[3] = salt_buf1[3];
  w2_t[0] = salt_buf2[0];
  w2_t[1] = salt_buf2[1];
  w2_t[2] = salt_buf2[2];
  w2_t[3] = salt_buf2[3];
  w3_t[0] = salt_buf3[0];
  w3_t[1] = salt_buf3[1];
  w3_t[2] = salt_buf3[2];
  w3_t[3] = salt_buf3[3];

  u64x ipad[8];
  u64x opad[8];

  hmac_sha512_pad (w0_t, w1_t, w2_t, w3_t, ipad, opad);

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

  u32 w0l = w0[0];

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x w0r = ix_create_bft (bfs_buf, il_pos);

    const u32x w0lr = w0l | w0r;

    w0_t[0] = w0lr;
    w0_t[1] = w0[1];
    w0_t[2] = w0[2];
    w0_t[3] = w0[3];
    w1_t[0] = w1[0];
    w1_t[1] = w1[1];
    w1_t[2] = w1[2];
    w1_t[3] = w1[3];
    w2_t[0] = w2[0];
    w2_t[1] = w2[1];
    w2_t[2] = w2[2];
    w2_t[3] = w2[3];
    w3_t[0] = w3[0];
    w3_t[1] = w3[1];
    w3_t[2] = 0;
    w3_t[3] = (128 + pw_len) * 8;

    u64x digest[8];

    hmac_sha512_run (w0_t, w1_t, w2_t, w3_t, ipad, opad, digest);

    const u32x r0 = l32_from_64 (digest[7]);
    const u32x r1 = h32_from_64 (digest[7]);
    const u32x r2 = l32_from_64 (digest[3]);
    const u32x r3 = h32_from_64 (digest[3]);

    COMPARE_S_SIMD (r0, r1, r2, r3);
  }
}

__kernel void m01760_m04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = 0;
  w1[1] = 0;
  w1[2] = 0;
  w1[3] = 0;

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m01760m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m01760_m08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m01760m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m01760_m16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = pws[gid].i[ 8];
  w2[1] = pws[gid].i[ 9];
  w2[2] = pws[gid].i[10];
  w2[3] = pws[gid].i[11];

  u32 w3[4];

  w3[0] = pws[gid].i[12];
  w3[1] = pws[gid].i[13];
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m01760m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m01760_s04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = 0;
  w1[1] = 0;
  w1[2] = 0;
  w1[3] = 0;

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m01760s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m01760_s08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;

  u32 w3[4];

  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m01760s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m01760_s16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 w0[4];

  w0[0] = pws[gid].i[ 0];
  w0[1] = pws[gid].i[ 1];
  w0[2] = pws[gid].i[ 2];
  w0[3] = pws[gid].i[ 3];

  u32 w1[4];

  w1[0] = pws[gid].i[ 4];
  w1[1] = pws[gid].i[ 5];
  w1[2] = pws[gid].i[ 6];
  w1[3] = pws[gid].i[ 7];

  u32 w2[4];

  w2[0] = pws[gid].i[ 8];
  w2[1] = pws[gid].i[ 9];
  w2[2] = pws[gid].i[10];
  w2[3] = pws[gid].i[11];

  u32 w3[4];

  w3[0] = pws[gid].i[12];
  w3[1] = pws[gid].i[13];
  w3[2] = 0;
  w3[3] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m01760s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}
