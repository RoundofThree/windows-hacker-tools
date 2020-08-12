/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//incompatible data-dependant code
//#define NEW_SIMD_CODE

#include "inc_vendor.cl"
#include "inc_hash_constants.h"
#include "inc_hash_functions.cl"
#include "inc_types.cl"
#include "inc_common.cl"
#include "inc_simd.cl"
#include "inc_hash_sha1.cl"

__constant u32a theMagicArray[64] =
{
  0x91ac5114, 0x9f675443, 0x24e73be0, 0x28747bc2, 0x863313eb, 0x5a4fcb5c, 0x080a7337, 0x0e5d1c2f,
  0x338fe6e5, 0xf89baedd, 0x16f24b8d, 0x2ce1d4dc, 0xb0cbdf9d, 0xd4706d17, 0xf94d423f, 0x9b1b1194,
  0x9f5bc19b, 0x06059d03, 0x9d5e138a, 0x1e9a6ae8, 0xd97c1417, 0x58c72af6, 0xa199630a, 0xd7fd70c3,
  0xf65e7413, 0x03c90b04, 0x2698f726, 0x8a929325, 0xb0a20d23, 0xed63796d, 0x1332fa3c, 0x35029aa3,
  0xb3dd8e0a, 0x24bf51c3, 0x7ccd559f, 0x37af944c, 0x29085282, 0xb23b4e37, 0x9f170791, 0x113bfdcd,
  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
  0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
};

DECLSPEC u32 GETSHIFTEDINT_CONST (__constant u32 *a, const int n)
{
  const int d = n / 4;
  const int m = n & 3;

  u64 tmp = hl32_to_64_S (a[d + 0], a[d + 1]);

  tmp <<= m * 8;

  return h32_from_64_S (tmp);
}

DECLSPEC void SETSHIFTEDINT (u32 *a, const int n, const u32 v)
{
  const int d = n / 4;
  const int m = n & 3;

  u64 tmp = hl32_to_64_S (v, 0);

  tmp >>= m * 8;

  a[d + 0] |= h32_from_64_S (tmp);
  a[d + 1]  = l32_from_64_S (tmp);
}

DECLSPEC void m07800m (u32 w0[4], u32 w1[4], u32 w2[4], u32 w3[4], const u32 pw_len, __global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);

  /**
   * salt
   */

  u32 salt_buf[8];

  salt_buf[0] = swap32_S (salt_bufs[salt_pos].salt_buf[0]);
  salt_buf[1] = swap32_S (salt_bufs[salt_pos].salt_buf[1]);
  salt_buf[2] = swap32_S (salt_bufs[salt_pos].salt_buf[2]);
  salt_buf[3] = swap32_S (salt_bufs[salt_pos].salt_buf[3]);
  salt_buf[4] = swap32_S (salt_bufs[salt_pos].salt_buf[4]);
  salt_buf[5] = swap32_S (salt_bufs[salt_pos].salt_buf[5]);
  salt_buf[6] = swap32_S (salt_bufs[salt_pos].salt_buf[6]);
  salt_buf[7] = swap32_S (salt_bufs[salt_pos].salt_buf[7]);

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  u32 s0[4];
  u32 s1[4];
  u32 s2[4];
  u32 s3[4];

  s0[0] = salt_buf[0];
  s0[1] = salt_buf[1];
  s0[2] = salt_buf[2];
  s0[3] = salt_buf[3];
  s1[0] = salt_buf[4];
  s1[1] = salt_buf[5];
  s1[2] = salt_buf[6];
  s1[3] = salt_buf[7];
  s2[0] = 0;
  s2[1] = 0;
  s2[2] = 0;
  s2[3] = 0;
  s3[0] = 0;
  s3[1] = 0;
  s3[2] = 0;
  s3[3] = 0;

  switch_buffer_by_offset_be_S (s0, s1, s2, s3, pw_len);

  const u32x pw_salt_len = pw_len + salt_len;

  /**
   * loop
   */

  u32 w0l = w0[0];

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x w0r = ix_create_bft (bfs_buf, il_pos);

    const u32x w0lr = w0l | w0r;

    w0[0] = w0lr;

    /**
     * SAP
     */

    u32 final[32];

    final[ 0] = w0[0] | s0[0];
    final[ 1] = w0[1] | s0[1];
    final[ 2] = w0[2] | s0[2];
    final[ 3] = w0[3] | s0[3];
    final[ 4] = w1[0] | s1[0];
    final[ 5] = w1[1] | s1[1];
    final[ 6] = w1[2] | s1[2];
    final[ 7] = w1[3] | s1[3];
    final[ 8] = w2[0] | s2[0];
    final[ 9] = w2[1] | s2[1];
    final[10] = w2[2] | s2[2];
    final[11] = w2[3] | s2[3];
    final[12] = w3[0] | s3[0];
    final[13] = w3[1] | s3[1];
    final[14] = 0;
    final[15] = pw_salt_len * 8;
    final[16] = 0;
    final[17] = 0;
    final[18] = 0;
    final[19] = 0;
    final[20] = 0;
    final[21] = 0;
    final[22] = 0;
    final[23] = 0;
    final[24] = 0;
    final[25] = 0;
    final[26] = 0;
    final[27] = 0;
    final[28] = 0;
    final[29] = 0;
    final[30] = 0;
    final[31] = 0;

    u32 digest[5];

    digest[0] = SHA1M_A;
    digest[1] = SHA1M_B;
    digest[2] = SHA1M_C;
    digest[3] = SHA1M_D;
    digest[4] = SHA1M_E;

    sha1_transform (&final[0], &final[4], &final[8], &final[12], digest);

    // prepare magic array range

    u32 lengthMagicArray = 0x20;
    u32 offsetMagicArray = 0;

    lengthMagicArray += ((digest[0] >> 24) & 0xff) % 6;
    lengthMagicArray += ((digest[0] >> 16) & 0xff) % 6;
    lengthMagicArray += ((digest[0] >>  8) & 0xff) % 6;
    lengthMagicArray += ((digest[0] >>  0) & 0xff) % 6;
    lengthMagicArray += ((digest[1] >> 24) & 0xff) % 6;
    lengthMagicArray += ((digest[1] >> 16) & 0xff) % 6;
    lengthMagicArray += ((digest[1] >>  8) & 0xff) % 6;
    lengthMagicArray += ((digest[1] >>  0) & 0xff) % 6;
    lengthMagicArray += ((digest[2] >> 24) & 0xff) % 6;
    lengthMagicArray += ((digest[2] >> 16) & 0xff) % 6;
    offsetMagicArray += ((digest[2] >>  8) & 0xff) % 8;
    offsetMagicArray += ((digest[2] >>  0) & 0xff) % 8;
    offsetMagicArray += ((digest[3] >> 24) & 0xff) % 8;
    offsetMagicArray += ((digest[3] >> 16) & 0xff) % 8;
    offsetMagicArray += ((digest[3] >>  8) & 0xff) % 8;
    offsetMagicArray += ((digest[3] >>  0) & 0xff) % 8;
    offsetMagicArray += ((digest[4] >> 24) & 0xff) % 8;
    offsetMagicArray += ((digest[4] >> 16) & 0xff) % 8;
    offsetMagicArray += ((digest[4] >>  8) & 0xff) % 8;
    offsetMagicArray += ((digest[4] >>  0) & 0xff) % 8;

    // final

    digest[0] = SHA1M_A;
    digest[1] = SHA1M_B;
    digest[2] = SHA1M_C;
    digest[3] = SHA1M_D;
    digest[4] = SHA1M_E;

    final[ 0] = w0[0];
    final[ 1] = w0[1];
    final[ 2] = w0[2];
    final[ 3] = w0[3];
    final[ 4] = w1[0];
    final[ 5] = w1[1];
    final[ 6] = w1[2];
    final[ 7] = w1[3];
    final[ 8] = 0;
    final[ 9] = 0;
    final[10] = 0;
    final[11] = 0;
    final[12] = 0;
    final[13] = 0;
    final[14] = 0;
    final[15] = 0;

    u32 final_len = pw_len;

    u32 i;

    // append MagicArray

    for (i = 0; i < lengthMagicArray - 4; i += 4)
    {
      const u32 tmp = GETSHIFTEDINT_CONST (theMagicArray, offsetMagicArray + i);

      SETSHIFTEDINT (final, final_len + i, tmp);
    }

    const u32 mask = 0xffffffff << (((4 - (lengthMagicArray - i)) & 3) * 8);

    const u32 tmp = GETSHIFTEDINT_CONST (theMagicArray, offsetMagicArray + i) & mask;

    SETSHIFTEDINT (final, final_len + i, tmp);

    final_len += lengthMagicArray;

    // append Salt

    for (i = 0; i < salt_len + 1; i += 4) // +1 for the 0x80
    {
      const u32 tmp = salt_buf[i / 4]; // attention, int[] not char[]

      SETSHIFTEDINT (final, final_len + i, tmp);
    }

    final_len += salt_len;

    // calculate

    int left;
    int off;

    for (left = final_len, off = 0; left >= 56; left -= 64, off += 16)
    {
      sha1_transform (&final[off + 0], &final[off + 4], &final[off + 8], &final[off + 12], digest);
    }

    final[off + 15] = final_len * 8;

    sha1_transform (&final[off + 0], &final[off + 4], &final[off + 8], &final[off + 12], digest);

    COMPARE_M_SIMD (digest[3], digest[4], digest[2], digest[1]);
  }
}

DECLSPEC void m07800s (u32 w0[4], u32 w1[4], u32 w2[4], u32 w3[4], const u32 pw_len, __global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);

  /**
   * salt
   */

  u32 salt_buf[8];

  salt_buf[0] = swap32_S (salt_bufs[salt_pos].salt_buf[0]);
  salt_buf[1] = swap32_S (salt_bufs[salt_pos].salt_buf[1]);
  salt_buf[2] = swap32_S (salt_bufs[salt_pos].salt_buf[2]);
  salt_buf[3] = swap32_S (salt_bufs[salt_pos].salt_buf[3]);
  salt_buf[4] = swap32_S (salt_bufs[salt_pos].salt_buf[4]);
  salt_buf[5] = swap32_S (salt_bufs[salt_pos].salt_buf[5]);
  salt_buf[6] = swap32_S (salt_bufs[salt_pos].salt_buf[6]);
  salt_buf[7] = swap32_S (salt_bufs[salt_pos].salt_buf[7]);

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  u32 s0[4];
  u32 s1[4];
  u32 s2[4];
  u32 s3[4];

  s0[0] = salt_buf[0];
  s0[1] = salt_buf[1];
  s0[2] = salt_buf[2];
  s0[3] = salt_buf[3];
  s1[0] = salt_buf[4];
  s1[1] = salt_buf[5];
  s1[2] = salt_buf[6];
  s1[3] = salt_buf[7];
  s2[0] = 0;
  s2[1] = 0;
  s2[2] = 0;
  s2[3] = 0;
  s3[0] = 0;
  s3[1] = 0;
  s3[2] = 0;
  s3[3] = 0;

  switch_buffer_by_offset_be_S (s0, s1, s2, s3, pw_len);

  const u32x pw_salt_len = pw_len + salt_len;

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

    w0[0] = w0lr;

    /**
     * SAP
     */

    u32 final[32];

    final[ 0] = w0[0] | s0[0];
    final[ 1] = w0[1] | s0[1];
    final[ 2] = w0[2] | s0[2];
    final[ 3] = w0[3] | s0[3];
    final[ 4] = w1[0] | s1[0];
    final[ 5] = w1[1] | s1[1];
    final[ 6] = w1[2] | s1[2];
    final[ 7] = w1[3] | s1[3];
    final[ 8] = w2[0] | s2[0];
    final[ 9] = w2[1] | s2[1];
    final[10] = w2[2] | s2[2];
    final[11] = w2[3] | s2[3];
    final[12] = w3[0] | s3[0];
    final[13] = w3[1] | s3[1];
    final[14] = 0;
    final[15] = pw_salt_len * 8;
    final[16] = 0;
    final[17] = 0;
    final[18] = 0;
    final[19] = 0;
    final[20] = 0;
    final[21] = 0;
    final[22] = 0;
    final[23] = 0;
    final[24] = 0;
    final[25] = 0;
    final[26] = 0;
    final[27] = 0;
    final[28] = 0;
    final[29] = 0;
    final[30] = 0;
    final[31] = 0;

    u32 digest[5];

    digest[0] = SHA1M_A;
    digest[1] = SHA1M_B;
    digest[2] = SHA1M_C;
    digest[3] = SHA1M_D;
    digest[4] = SHA1M_E;

    sha1_transform (&final[0], &final[4], &final[8], &final[12], digest);

    // prepare magic array range

    u32 lengthMagicArray = 0x20;
    u32 offsetMagicArray = 0;

    lengthMagicArray += ((digest[0] >> 24) & 0xff) % 6;
    lengthMagicArray += ((digest[0] >> 16) & 0xff) % 6;
    lengthMagicArray += ((digest[0] >>  8) & 0xff) % 6;
    lengthMagicArray += ((digest[0] >>  0) & 0xff) % 6;
    lengthMagicArray += ((digest[1] >> 24) & 0xff) % 6;
    lengthMagicArray += ((digest[1] >> 16) & 0xff) % 6;
    lengthMagicArray += ((digest[1] >>  8) & 0xff) % 6;
    lengthMagicArray += ((digest[1] >>  0) & 0xff) % 6;
    lengthMagicArray += ((digest[2] >> 24) & 0xff) % 6;
    lengthMagicArray += ((digest[2] >> 16) & 0xff) % 6;
    offsetMagicArray += ((digest[2] >>  8) & 0xff) % 8;
    offsetMagicArray += ((digest[2] >>  0) & 0xff) % 8;
    offsetMagicArray += ((digest[3] >> 24) & 0xff) % 8;
    offsetMagicArray += ((digest[3] >> 16) & 0xff) % 8;
    offsetMagicArray += ((digest[3] >>  8) & 0xff) % 8;
    offsetMagicArray += ((digest[3] >>  0) & 0xff) % 8;
    offsetMagicArray += ((digest[4] >> 24) & 0xff) % 8;
    offsetMagicArray += ((digest[4] >> 16) & 0xff) % 8;
    offsetMagicArray += ((digest[4] >>  8) & 0xff) % 8;
    offsetMagicArray += ((digest[4] >>  0) & 0xff) % 8;

    // final

    digest[0] = SHA1M_A;
    digest[1] = SHA1M_B;
    digest[2] = SHA1M_C;
    digest[3] = SHA1M_D;
    digest[4] = SHA1M_E;

    final[ 0] = w0[0];
    final[ 1] = w0[1];
    final[ 2] = w0[2];
    final[ 3] = w0[3];
    final[ 4] = w1[0];
    final[ 5] = w1[1];
    final[ 6] = w1[2];
    final[ 7] = w1[3];
    final[ 8] = 0;
    final[ 9] = 0;
    final[10] = 0;
    final[11] = 0;
    final[12] = 0;
    final[13] = 0;
    final[14] = 0;
    final[15] = 0;

    u32 final_len = pw_len;

    u32 i;

    // append MagicArray

    for (i = 0; i < lengthMagicArray - 4; i += 4)
    {
      const u32 tmp = GETSHIFTEDINT_CONST (theMagicArray, offsetMagicArray + i);

      SETSHIFTEDINT (final, final_len + i, tmp);
    }

    const u32 mask = 0xffffffff << (((4 - (lengthMagicArray - i)) & 3) * 8);

    const u32 tmp = GETSHIFTEDINT_CONST (theMagicArray, offsetMagicArray + i) & mask;

    SETSHIFTEDINT (final, final_len + i, tmp);

    final_len += lengthMagicArray;

    // append Salt

    for (i = 0; i < salt_len + 1; i += 4) // +1 for the 0x80
    {
      const u32 tmp = salt_buf[i / 4]; // attention, int[] not char[]

      SETSHIFTEDINT (final, final_len + i, tmp);
    }

    final_len += salt_len;

    // calculate

    int left;
    int off;

    for (left = final_len, off = 0; left >= 56; left -= 64, off += 16)
    {
      sha1_transform (&final[off + 0], &final[off + 4], &final[off + 8], &final[off + 12], digest);
    }

    final[off + 15] = final_len * 8;

    sha1_transform (&final[off + 0], &final[off + 4], &final[off + 8], &final[off + 12], digest);

    COMPARE_S_SIMD (digest[3], digest[4], digest[2], digest[1]);
  }
}

__kernel void m07800_m04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * modifier
   */

  //const u64 lid = get_local_id (0);

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

  m07800m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m07800_m08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * modifier
   */

  //const u64 lid = get_local_id (0);

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

  m07800m (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m07800_m16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m07800_s04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * modifier
   */

  //const u64 lid = get_local_id (0);

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

  m07800s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m07800_s08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * modifier
   */

  //const u64 lid = get_local_id (0);

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

  m07800s (w0, w1, w2, w3, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m07800_s16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}
