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
#include "inc_hash_sha1.cl"

DECLSPEC void hmac_sha1_pad (u32x w0[4], u32x w1[4], u32x w2[4], u32x w3[4], u32x ipad[5], u32x opad[5])
{
  w0[0] = w0[0] ^ 0x36363636;
  w0[1] = w0[1] ^ 0x36363636;
  w0[2] = w0[2] ^ 0x36363636;
  w0[3] = w0[3] ^ 0x36363636;
  w1[0] = w1[0] ^ 0x36363636;
  w1[1] = w1[1] ^ 0x36363636;
  w1[2] = w1[2] ^ 0x36363636;
  w1[3] = w1[3] ^ 0x36363636;
  w2[0] = w2[0] ^ 0x36363636;
  w2[1] = w2[1] ^ 0x36363636;
  w2[2] = w2[2] ^ 0x36363636;
  w2[3] = w2[3] ^ 0x36363636;
  w3[0] = w3[0] ^ 0x36363636;
  w3[1] = w3[1] ^ 0x36363636;
  w3[2] = w3[2] ^ 0x36363636;
  w3[3] = w3[3] ^ 0x36363636;

  ipad[0] = SHA1M_A;
  ipad[1] = SHA1M_B;
  ipad[2] = SHA1M_C;
  ipad[3] = SHA1M_D;
  ipad[4] = SHA1M_E;

  sha1_transform_vector (w0, w1, w2, w3, ipad);

  w0[0] = w0[0] ^ 0x6a6a6a6a;
  w0[1] = w0[1] ^ 0x6a6a6a6a;
  w0[2] = w0[2] ^ 0x6a6a6a6a;
  w0[3] = w0[3] ^ 0x6a6a6a6a;
  w1[0] = w1[0] ^ 0x6a6a6a6a;
  w1[1] = w1[1] ^ 0x6a6a6a6a;
  w1[2] = w1[2] ^ 0x6a6a6a6a;
  w1[3] = w1[3] ^ 0x6a6a6a6a;
  w2[0] = w2[0] ^ 0x6a6a6a6a;
  w2[1] = w2[1] ^ 0x6a6a6a6a;
  w2[2] = w2[2] ^ 0x6a6a6a6a;
  w2[3] = w2[3] ^ 0x6a6a6a6a;
  w3[0] = w3[0] ^ 0x6a6a6a6a;
  w3[1] = w3[1] ^ 0x6a6a6a6a;
  w3[2] = w3[2] ^ 0x6a6a6a6a;
  w3[3] = w3[3] ^ 0x6a6a6a6a;

  opad[0] = SHA1M_A;
  opad[1] = SHA1M_B;
  opad[2] = SHA1M_C;
  opad[3] = SHA1M_D;
  opad[4] = SHA1M_E;

  sha1_transform_vector (w0, w1, w2, w3, opad);
}

DECLSPEC void hmac_sha1_run (u32x w0[4], u32x w1[4], u32x w2[4], u32x w3[4], u32x ipad[5], u32x opad[5], u32x digest[5])
{
  digest[0] = ipad[0];
  digest[1] = ipad[1];
  digest[2] = ipad[2];
  digest[3] = ipad[3];
  digest[4] = ipad[4];

  sha1_transform_vector (w0, w1, w2, w3, digest);

  w0[0] = digest[0];
  w0[1] = digest[1];
  w0[2] = digest[2];
  w0[3] = digest[3];
  w1[0] = digest[4];
  w1[1] = 0x80000000;
  w1[2] = 0;
  w1[3] = 0;
  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;
  w3[0] = 0;
  w3[1] = 0;
  w3[2] = 0;
  w3[3] = (64 + 20) * 8;

  digest[0] = opad[0];
  digest[1] = opad[1];
  digest[2] = opad[2];
  digest[3] = opad[3];
  digest[4] = opad[4];

  sha1_transform_vector (w0, w1, w2, w3, digest);
}

__kernel void m07300_m04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global rakp_t *rakp_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);

  /**
   * base
   */

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

  const u32 pw_l_len = pws[gid].pw_len;

  /**
   * salt
   */

  const u32 esalt_len = rakp_bufs[digests_offset].salt_len;

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x pw_r_len = pwlenx_create_combt (combs_buf, il_pos);

    const u32x pw_len = pw_l_len + pw_r_len;

    /**
     * concat password candidate
     */

    u32x wordl0[4] = { 0 };
    u32x wordl1[4] = { 0 };
    u32x wordl2[4] = { 0 };
    u32x wordl3[4] = { 0 };

    wordl0[0] = pw_buf0[0];
    wordl0[1] = pw_buf0[1];
    wordl0[2] = pw_buf0[2];
    wordl0[3] = pw_buf0[3];
    wordl1[0] = pw_buf1[0];
    wordl1[1] = pw_buf1[1];
    wordl1[2] = pw_buf1[2];
    wordl1[3] = pw_buf1[3];

    u32x wordr0[4] = { 0 };
    u32x wordr1[4] = { 0 };
    u32x wordr2[4] = { 0 };
    u32x wordr3[4] = { 0 };

    wordr0[0] = ix_create_combt (combs_buf, il_pos, 0);
    wordr0[1] = ix_create_combt (combs_buf, il_pos, 1);
    wordr0[2] = ix_create_combt (combs_buf, il_pos, 2);
    wordr0[3] = ix_create_combt (combs_buf, il_pos, 3);
    wordr1[0] = ix_create_combt (combs_buf, il_pos, 4);
    wordr1[1] = ix_create_combt (combs_buf, il_pos, 5);
    wordr1[2] = ix_create_combt (combs_buf, il_pos, 6);
    wordr1[3] = ix_create_combt (combs_buf, il_pos, 7);

    if (combs_mode == COMBINATOR_MODE_BASE_LEFT)
    {
      switch_buffer_by_offset_le_VV (wordr0, wordr1, wordr2, wordr3, pw_l_len);
    }
    else
    {
      switch_buffer_by_offset_le_VV (wordl0, wordl1, wordl2, wordl3, pw_r_len);
    }

    u32x w0[4];
    u32x w1[4];
    u32x w2[4];
    u32x w3[4];

    w0[0] = wordl0[0] | wordr0[0];
    w0[1] = wordl0[1] | wordr0[1];
    w0[2] = wordl0[2] | wordr0[2];
    w0[3] = wordl0[3] | wordr0[3];
    w1[0] = wordl1[0] | wordr1[0];
    w1[1] = wordl1[1] | wordr1[1];
    w1[2] = wordl1[2] | wordr1[2];
    w1[3] = wordl1[3] | wordr1[3];
    w2[0] = wordl2[0] | wordr2[0];
    w2[1] = wordl2[1] | wordr2[1];
    w2[2] = wordl2[2] | wordr2[2];
    w2[3] = wordl2[3] | wordr2[3];
    w3[0] = wordl3[0] | wordr3[0];
    w3[1] = wordl3[1] | wordr3[1];
    w3[2] = wordl3[2] | wordr3[2];
    w3[3] = wordl3[3] | wordr3[3];

    w0[0] = swap32 (w0[0]);
    w0[1] = swap32 (w0[1]);
    w0[2] = swap32 (w0[2]);
    w0[3] = swap32 (w0[3]);
    w1[0] = swap32 (w1[0]);
    w1[1] = swap32 (w1[1]);
    w1[2] = swap32 (w1[2]);
    w1[3] = swap32 (w1[3]);
    w2[0] = swap32 (w2[0]);
    w2[1] = swap32 (w2[1]);
    w2[2] = swap32 (w2[2]);
    w2[3] = swap32 (w2[3]);
    w3[0] = swap32 (w3[0]);
    w3[1] = swap32 (w3[1]);
    w3[2] = swap32 (w3[2]);
    w3[3] = swap32 (w3[3]);

    /**
     * RAKP
     */

    u32x ipad[5];
    u32x opad[5];

    hmac_sha1_pad (w0, w1, w2, w3, ipad, opad);

    int esalt_size = esalt_len;

    int esalt_left;
    int esalt_off;

    for (esalt_left = esalt_size, esalt_off = 0; esalt_left >= 56; esalt_left -= 64, esalt_off += 16)
    {
      w0[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  0];
      w0[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  1];
      w0[2] = rakp_bufs[digests_offset].salt_buf[esalt_off +  2];
      w0[3] = rakp_bufs[digests_offset].salt_buf[esalt_off +  3];
      w1[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  4];
      w1[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  5];
      w1[2] = rakp_bufs[digests_offset].salt_buf[esalt_off +  6];
      w1[3] = rakp_bufs[digests_offset].salt_buf[esalt_off +  7];
      w2[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  8];
      w2[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  9];
      w2[2] = rakp_bufs[digests_offset].salt_buf[esalt_off + 10];
      w2[3] = rakp_bufs[digests_offset].salt_buf[esalt_off + 11];
      w3[0] = rakp_bufs[digests_offset].salt_buf[esalt_off + 12];
      w3[1] = rakp_bufs[digests_offset].salt_buf[esalt_off + 13];
      w3[2] = rakp_bufs[digests_offset].salt_buf[esalt_off + 14];
      w3[3] = rakp_bufs[digests_offset].salt_buf[esalt_off + 15];

      sha1_transform_vector (w0, w1, w2, w3, ipad);
    }

    w0[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  0];
    w0[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  1];
    w0[2] = rakp_bufs[digests_offset].salt_buf[esalt_off +  2];
    w0[3] = rakp_bufs[digests_offset].salt_buf[esalt_off +  3];
    w1[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  4];
    w1[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  5];
    w1[2] = rakp_bufs[digests_offset].salt_buf[esalt_off +  6];
    w1[3] = rakp_bufs[digests_offset].salt_buf[esalt_off +  7];
    w2[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  8];
    w2[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  9];
    w2[2] = rakp_bufs[digests_offset].salt_buf[esalt_off + 10];
    w2[3] = rakp_bufs[digests_offset].salt_buf[esalt_off + 11];
    w3[0] = rakp_bufs[digests_offset].salt_buf[esalt_off + 12];
    w3[1] = rakp_bufs[digests_offset].salt_buf[esalt_off + 13];
    w3[2] = 0;
    w3[3] = (64 + esalt_size) * 8;

    u32x digest[5];

    hmac_sha1_run (w0, w1, w2, w3, ipad, opad, digest);

    COMPARE_M_SIMD (digest[3], digest[4], digest[2], digest[1]);
  }
}

__kernel void m07300_m08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global rakp_t *rakp_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m07300_m16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global rakp_t *rakp_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m07300_s04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global rakp_t *rakp_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);

  /**
   * base
   */

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

  const u32 pw_l_len = pws[gid].pw_len;

  /**
   * salt
   */

  const u32 esalt_len = rakp_bufs[digests_offset].salt_len;

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
    const u32x pw_r_len = pwlenx_create_combt (combs_buf, il_pos);

    const u32x pw_len = pw_l_len + pw_r_len;

    /**
     * concat password candidate
     */

    u32x wordl0[4] = { 0 };
    u32x wordl1[4] = { 0 };
    u32x wordl2[4] = { 0 };
    u32x wordl3[4] = { 0 };

    wordl0[0] = pw_buf0[0];
    wordl0[1] = pw_buf0[1];
    wordl0[2] = pw_buf0[2];
    wordl0[3] = pw_buf0[3];
    wordl1[0] = pw_buf1[0];
    wordl1[1] = pw_buf1[1];
    wordl1[2] = pw_buf1[2];
    wordl1[3] = pw_buf1[3];

    u32x wordr0[4] = { 0 };
    u32x wordr1[4] = { 0 };
    u32x wordr2[4] = { 0 };
    u32x wordr3[4] = { 0 };

    wordr0[0] = ix_create_combt (combs_buf, il_pos, 0);
    wordr0[1] = ix_create_combt (combs_buf, il_pos, 1);
    wordr0[2] = ix_create_combt (combs_buf, il_pos, 2);
    wordr0[3] = ix_create_combt (combs_buf, il_pos, 3);
    wordr1[0] = ix_create_combt (combs_buf, il_pos, 4);
    wordr1[1] = ix_create_combt (combs_buf, il_pos, 5);
    wordr1[2] = ix_create_combt (combs_buf, il_pos, 6);
    wordr1[3] = ix_create_combt (combs_buf, il_pos, 7);

    if (combs_mode == COMBINATOR_MODE_BASE_LEFT)
    {
      switch_buffer_by_offset_le_VV (wordr0, wordr1, wordr2, wordr3, pw_l_len);
    }
    else
    {
      switch_buffer_by_offset_le_VV (wordl0, wordl1, wordl2, wordl3, pw_r_len);
    }

    u32x w0[4];
    u32x w1[4];
    u32x w2[4];
    u32x w3[4];

    w0[0] = wordl0[0] | wordr0[0];
    w0[1] = wordl0[1] | wordr0[1];
    w0[2] = wordl0[2] | wordr0[2];
    w0[3] = wordl0[3] | wordr0[3];
    w1[0] = wordl1[0] | wordr1[0];
    w1[1] = wordl1[1] | wordr1[1];
    w1[2] = wordl1[2] | wordr1[2];
    w1[3] = wordl1[3] | wordr1[3];
    w2[0] = wordl2[0] | wordr2[0];
    w2[1] = wordl2[1] | wordr2[1];
    w2[2] = wordl2[2] | wordr2[2];
    w2[3] = wordl2[3] | wordr2[3];
    w3[0] = wordl3[0] | wordr3[0];
    w3[1] = wordl3[1] | wordr3[1];
    w3[2] = wordl3[2] | wordr3[2];
    w3[3] = wordl3[3] | wordr3[3];

    w0[0] = swap32 (w0[0]);
    w0[1] = swap32 (w0[1]);
    w0[2] = swap32 (w0[2]);
    w0[3] = swap32 (w0[3]);
    w1[0] = swap32 (w1[0]);
    w1[1] = swap32 (w1[1]);
    w1[2] = swap32 (w1[2]);
    w1[3] = swap32 (w1[3]);
    w2[0] = swap32 (w2[0]);
    w2[1] = swap32 (w2[1]);
    w2[2] = swap32 (w2[2]);
    w2[3] = swap32 (w2[3]);
    w3[0] = swap32 (w3[0]);
    w3[1] = swap32 (w3[1]);
    w3[2] = swap32 (w3[2]);
    w3[3] = swap32 (w3[3]);

    /**
     * RAKP
     */

    u32x ipad[5];
    u32x opad[5];

    hmac_sha1_pad (w0, w1, w2, w3, ipad, opad);

    int esalt_size = esalt_len;

    int esalt_left;
    int esalt_off;

    for (esalt_left = esalt_size, esalt_off = 0; esalt_left >= 56; esalt_left -= 64, esalt_off += 16)
    {
      w0[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  0];
      w0[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  1];
      w0[2] = rakp_bufs[digests_offset].salt_buf[esalt_off +  2];
      w0[3] = rakp_bufs[digests_offset].salt_buf[esalt_off +  3];
      w1[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  4];
      w1[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  5];
      w1[2] = rakp_bufs[digests_offset].salt_buf[esalt_off +  6];
      w1[3] = rakp_bufs[digests_offset].salt_buf[esalt_off +  7];
      w2[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  8];
      w2[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  9];
      w2[2] = rakp_bufs[digests_offset].salt_buf[esalt_off + 10];
      w2[3] = rakp_bufs[digests_offset].salt_buf[esalt_off + 11];
      w3[0] = rakp_bufs[digests_offset].salt_buf[esalt_off + 12];
      w3[1] = rakp_bufs[digests_offset].salt_buf[esalt_off + 13];
      w3[2] = rakp_bufs[digests_offset].salt_buf[esalt_off + 14];
      w3[3] = rakp_bufs[digests_offset].salt_buf[esalt_off + 15];

      sha1_transform_vector (w0, w1, w2, w3, ipad);
    }

    w0[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  0];
    w0[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  1];
    w0[2] = rakp_bufs[digests_offset].salt_buf[esalt_off +  2];
    w0[3] = rakp_bufs[digests_offset].salt_buf[esalt_off +  3];
    w1[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  4];
    w1[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  5];
    w1[2] = rakp_bufs[digests_offset].salt_buf[esalt_off +  6];
    w1[3] = rakp_bufs[digests_offset].salt_buf[esalt_off +  7];
    w2[0] = rakp_bufs[digests_offset].salt_buf[esalt_off +  8];
    w2[1] = rakp_bufs[digests_offset].salt_buf[esalt_off +  9];
    w2[2] = rakp_bufs[digests_offset].salt_buf[esalt_off + 10];
    w2[3] = rakp_bufs[digests_offset].salt_buf[esalt_off + 11];
    w3[0] = rakp_bufs[digests_offset].salt_buf[esalt_off + 12];
    w3[1] = rakp_bufs[digests_offset].salt_buf[esalt_off + 13];
    w3[2] = 0;
    w3[3] = (64 + esalt_size) * 8;

    u32x digest[5];

    hmac_sha1_run (w0, w1, w2, w3, ipad, opad, digest);

    COMPARE_S_SIMD (digest[3], digest[4], digest[2], digest[1]);
  }
}

__kernel void m07300_s08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global rakp_t *rakp_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m07300_s16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global rakp_t *rakp_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}
