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

__kernel void m08100_m04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
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

  u32 salt_buf0[2];

  salt_buf0[0] = salt_bufs[salt_pos].salt_buf[0];
  salt_buf0[1] = salt_bufs[salt_pos].salt_buf[1];

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

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

    append_0x80_4x4_VV (w0, w1, w2, w3, pw_len + 1);

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

    /**
     * prepend salt
     */

    const u32x pw_salt_len = pw_len + salt_len;

    u32x w0_t[4];
    u32x w1_t[4];
    u32x w2_t[4];
    u32x w3_t[4];

    w0_t[0] = salt_buf0[0];
    w0_t[1] = salt_buf0[1];
    w0_t[2] = w0[0];
    w0_t[3] = w0[1];
    w1_t[0] = w0[2];
    w1_t[1] = w0[3];
    w1_t[2] = w1[0];
    w1_t[3] = w1[1];
    w2_t[0] = w1[2];
    w2_t[1] = w1[3];
    w2_t[2] = w2[0];
    w2_t[3] = w2[1];
    w3_t[0] = w2[2];
    w3_t[1] = w2[3];
    w3_t[2] = 0;
    w3_t[3] = (pw_salt_len + 1) * 8;

    /**
     * sha1
     */

    u32x a = SHA1M_A;
    u32x b = SHA1M_B;
    u32x c = SHA1M_C;
    u32x d = SHA1M_D;
    u32x e = SHA1M_E;

    #undef K
    #define K SHA1C00

    SHA1_STEP (SHA1_F0o, a, b, c, d, e, w0_t[0]);
    SHA1_STEP (SHA1_F0o, e, a, b, c, d, w0_t[1]);
    SHA1_STEP (SHA1_F0o, d, e, a, b, c, w0_t[2]);
    SHA1_STEP (SHA1_F0o, c, d, e, a, b, w0_t[3]);
    SHA1_STEP (SHA1_F0o, b, c, d, e, a, w1_t[0]);
    SHA1_STEP (SHA1_F0o, a, b, c, d, e, w1_t[1]);
    SHA1_STEP (SHA1_F0o, e, a, b, c, d, w1_t[2]);
    SHA1_STEP (SHA1_F0o, d, e, a, b, c, w1_t[3]);
    SHA1_STEP (SHA1_F0o, c, d, e, a, b, w2_t[0]);
    SHA1_STEP (SHA1_F0o, b, c, d, e, a, w2_t[1]);
    SHA1_STEP (SHA1_F0o, a, b, c, d, e, w2_t[2]);
    SHA1_STEP (SHA1_F0o, e, a, b, c, d, w2_t[3]);
    SHA1_STEP (SHA1_F0o, d, e, a, b, c, w3_t[0]);
    SHA1_STEP (SHA1_F0o, c, d, e, a, b, w3_t[1]);
    SHA1_STEP (SHA1_F0o, b, c, d, e, a, w3_t[2]);
    SHA1_STEP (SHA1_F0o, a, b, c, d, e, w3_t[3]);
    w0_t[0] = rotl32 ((w3_t[1] ^ w2_t[0] ^ w0_t[2] ^ w0_t[0]), 1u); SHA1_STEP (SHA1_F0o, e, a, b, c, d, w0_t[0]);
    w0_t[1] = rotl32 ((w3_t[2] ^ w2_t[1] ^ w0_t[3] ^ w0_t[1]), 1u); SHA1_STEP (SHA1_F0o, d, e, a, b, c, w0_t[1]);
    w0_t[2] = rotl32 ((w3_t[3] ^ w2_t[2] ^ w1_t[0] ^ w0_t[2]), 1u); SHA1_STEP (SHA1_F0o, c, d, e, a, b, w0_t[2]);
    w0_t[3] = rotl32 ((w0_t[0] ^ w2_t[3] ^ w1_t[1] ^ w0_t[3]), 1u); SHA1_STEP (SHA1_F0o, b, c, d, e, a, w0_t[3]);

    #undef K
    #define K SHA1C01

    w1_t[0] = rotl32 ((w0_t[1] ^ w3_t[0] ^ w1_t[2] ^ w1_t[0]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w1_t[0]);
    w1_t[1] = rotl32 ((w0_t[2] ^ w3_t[1] ^ w1_t[3] ^ w1_t[1]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w1_t[1]);
    w1_t[2] = rotl32 ((w0_t[3] ^ w3_t[2] ^ w2_t[0] ^ w1_t[2]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w1_t[2]);
    w1_t[3] = rotl32 ((w1_t[0] ^ w3_t[3] ^ w2_t[1] ^ w1_t[3]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w1_t[3]);
    w2_t[0] = rotl32 ((w1_t[1] ^ w0_t[0] ^ w2_t[2] ^ w2_t[0]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w2_t[0]);
    w2_t[1] = rotl32 ((w1_t[2] ^ w0_t[1] ^ w2_t[3] ^ w2_t[1]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w2_t[1]);
    w2_t[2] = rotl32 ((w1_t[3] ^ w0_t[2] ^ w3_t[0] ^ w2_t[2]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w2_t[2]);
    w2_t[3] = rotl32 ((w2_t[0] ^ w0_t[3] ^ w3_t[1] ^ w2_t[3]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w2_t[3]);
    w3_t[0] = rotl32 ((w2_t[1] ^ w1_t[0] ^ w3_t[2] ^ w3_t[0]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w3_t[0]);
    w3_t[1] = rotl32 ((w2_t[2] ^ w1_t[1] ^ w3_t[3] ^ w3_t[1]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w3_t[1]);
    w3_t[2] = rotl32 ((w2_t[3] ^ w1_t[2] ^ w0_t[0] ^ w3_t[2]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w3_t[2]);
    w3_t[3] = rotl32 ((w3_t[0] ^ w1_t[3] ^ w0_t[1] ^ w3_t[3]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w3_t[3]);
    w0_t[0] = rotl32 ((w3_t[1] ^ w2_t[0] ^ w0_t[2] ^ w0_t[0]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w0_t[0]);
    w0_t[1] = rotl32 ((w3_t[2] ^ w2_t[1] ^ w0_t[3] ^ w0_t[1]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w0_t[1]);
    w0_t[2] = rotl32 ((w3_t[3] ^ w2_t[2] ^ w1_t[0] ^ w0_t[2]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w0_t[2]);
    w0_t[3] = rotl32 ((w0_t[0] ^ w2_t[3] ^ w1_t[1] ^ w0_t[3]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w0_t[3]);
    w1_t[0] = rotl32 ((w0_t[1] ^ w3_t[0] ^ w1_t[2] ^ w1_t[0]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w1_t[0]);
    w1_t[1] = rotl32 ((w0_t[2] ^ w3_t[1] ^ w1_t[3] ^ w1_t[1]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w1_t[1]);
    w1_t[2] = rotl32 ((w0_t[3] ^ w3_t[2] ^ w2_t[0] ^ w1_t[2]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w1_t[2]);
    w1_t[3] = rotl32 ((w1_t[0] ^ w3_t[3] ^ w2_t[1] ^ w1_t[3]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w1_t[3]);

    #undef K
    #define K SHA1C02

    w2_t[0] = rotl32 ((w1_t[1] ^ w0_t[0] ^ w2_t[2] ^ w2_t[0]), 1u); SHA1_STEP (SHA1_F2o, a, b, c, d, e, w2_t[0]);
    w2_t[1] = rotl32 ((w1_t[2] ^ w0_t[1] ^ w2_t[3] ^ w2_t[1]), 1u); SHA1_STEP (SHA1_F2o, e, a, b, c, d, w2_t[1]);
    w2_t[2] = rotl32 ((w1_t[3] ^ w0_t[2] ^ w3_t[0] ^ w2_t[2]), 1u); SHA1_STEP (SHA1_F2o, d, e, a, b, c, w2_t[2]);
    w2_t[3] = rotl32 ((w2_t[0] ^ w0_t[3] ^ w3_t[1] ^ w2_t[3]), 1u); SHA1_STEP (SHA1_F2o, c, d, e, a, b, w2_t[3]);
    w3_t[0] = rotl32 ((w2_t[1] ^ w1_t[0] ^ w3_t[2] ^ w3_t[0]), 1u); SHA1_STEP (SHA1_F2o, b, c, d, e, a, w3_t[0]);
    w3_t[1] = rotl32 ((w2_t[2] ^ w1_t[1] ^ w3_t[3] ^ w3_t[1]), 1u); SHA1_STEP (SHA1_F2o, a, b, c, d, e, w3_t[1]);
    w3_t[2] = rotl32 ((w2_t[3] ^ w1_t[2] ^ w0_t[0] ^ w3_t[2]), 1u); SHA1_STEP (SHA1_F2o, e, a, b, c, d, w3_t[2]);
    w3_t[3] = rotl32 ((w3_t[0] ^ w1_t[3] ^ w0_t[1] ^ w3_t[3]), 1u); SHA1_STEP (SHA1_F2o, d, e, a, b, c, w3_t[3]);
    w0_t[0] = rotl32 ((w3_t[1] ^ w2_t[0] ^ w0_t[2] ^ w0_t[0]), 1u); SHA1_STEP (SHA1_F2o, c, d, e, a, b, w0_t[0]);
    w0_t[1] = rotl32 ((w3_t[2] ^ w2_t[1] ^ w0_t[3] ^ w0_t[1]), 1u); SHA1_STEP (SHA1_F2o, b, c, d, e, a, w0_t[1]);
    w0_t[2] = rotl32 ((w3_t[3] ^ w2_t[2] ^ w1_t[0] ^ w0_t[2]), 1u); SHA1_STEP (SHA1_F2o, a, b, c, d, e, w0_t[2]);
    w0_t[3] = rotl32 ((w0_t[0] ^ w2_t[3] ^ w1_t[1] ^ w0_t[3]), 1u); SHA1_STEP (SHA1_F2o, e, a, b, c, d, w0_t[3]);
    w1_t[0] = rotl32 ((w0_t[1] ^ w3_t[0] ^ w1_t[2] ^ w1_t[0]), 1u); SHA1_STEP (SHA1_F2o, d, e, a, b, c, w1_t[0]);
    w1_t[1] = rotl32 ((w0_t[2] ^ w3_t[1] ^ w1_t[3] ^ w1_t[1]), 1u); SHA1_STEP (SHA1_F2o, c, d, e, a, b, w1_t[1]);
    w1_t[2] = rotl32 ((w0_t[3] ^ w3_t[2] ^ w2_t[0] ^ w1_t[2]), 1u); SHA1_STEP (SHA1_F2o, b, c, d, e, a, w1_t[2]);
    w1_t[3] = rotl32 ((w1_t[0] ^ w3_t[3] ^ w2_t[1] ^ w1_t[3]), 1u); SHA1_STEP (SHA1_F2o, a, b, c, d, e, w1_t[3]);
    w2_t[0] = rotl32 ((w1_t[1] ^ w0_t[0] ^ w2_t[2] ^ w2_t[0]), 1u); SHA1_STEP (SHA1_F2o, e, a, b, c, d, w2_t[0]);
    w2_t[1] = rotl32 ((w1_t[2] ^ w0_t[1] ^ w2_t[3] ^ w2_t[1]), 1u); SHA1_STEP (SHA1_F2o, d, e, a, b, c, w2_t[1]);
    w2_t[2] = rotl32 ((w1_t[3] ^ w0_t[2] ^ w3_t[0] ^ w2_t[2]), 1u); SHA1_STEP (SHA1_F2o, c, d, e, a, b, w2_t[2]);
    w2_t[3] = rotl32 ((w2_t[0] ^ w0_t[3] ^ w3_t[1] ^ w2_t[3]), 1u); SHA1_STEP (SHA1_F2o, b, c, d, e, a, w2_t[3]);

    #undef K
    #define K SHA1C03

    w3_t[0] = rotl32 ((w2_t[1] ^ w1_t[0] ^ w3_t[2] ^ w3_t[0]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w3_t[0]);
    w3_t[1] = rotl32 ((w2_t[2] ^ w1_t[1] ^ w3_t[3] ^ w3_t[1]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w3_t[1]);
    w3_t[2] = rotl32 ((w2_t[3] ^ w1_t[2] ^ w0_t[0] ^ w3_t[2]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w3_t[2]);
    w3_t[3] = rotl32 ((w3_t[0] ^ w1_t[3] ^ w0_t[1] ^ w3_t[3]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w3_t[3]);
    w0_t[0] = rotl32 ((w3_t[1] ^ w2_t[0] ^ w0_t[2] ^ w0_t[0]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w0_t[0]);
    w0_t[1] = rotl32 ((w3_t[2] ^ w2_t[1] ^ w0_t[3] ^ w0_t[1]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w0_t[1]);
    w0_t[2] = rotl32 ((w3_t[3] ^ w2_t[2] ^ w1_t[0] ^ w0_t[2]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w0_t[2]);
    w0_t[3] = rotl32 ((w0_t[0] ^ w2_t[3] ^ w1_t[1] ^ w0_t[3]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w0_t[3]);
    w1_t[0] = rotl32 ((w0_t[1] ^ w3_t[0] ^ w1_t[2] ^ w1_t[0]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w1_t[0]);
    w1_t[1] = rotl32 ((w0_t[2] ^ w3_t[1] ^ w1_t[3] ^ w1_t[1]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w1_t[1]);
    w1_t[2] = rotl32 ((w0_t[3] ^ w3_t[2] ^ w2_t[0] ^ w1_t[2]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w1_t[2]);
    w1_t[3] = rotl32 ((w1_t[0] ^ w3_t[3] ^ w2_t[1] ^ w1_t[3]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w1_t[3]);
    w2_t[0] = rotl32 ((w1_t[1] ^ w0_t[0] ^ w2_t[2] ^ w2_t[0]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w2_t[0]);
    w2_t[1] = rotl32 ((w1_t[2] ^ w0_t[1] ^ w2_t[3] ^ w2_t[1]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w2_t[1]);
    w2_t[2] = rotl32 ((w1_t[3] ^ w0_t[2] ^ w3_t[0] ^ w2_t[2]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w2_t[2]);
    w2_t[3] = rotl32 ((w2_t[0] ^ w0_t[3] ^ w3_t[1] ^ w2_t[3]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w2_t[3]);
    w3_t[0] = rotl32 ((w2_t[1] ^ w1_t[0] ^ w3_t[2] ^ w3_t[0]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w3_t[0]);
    w3_t[1] = rotl32 ((w2_t[2] ^ w1_t[1] ^ w3_t[3] ^ w3_t[1]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w3_t[1]);
    w3_t[2] = rotl32 ((w2_t[3] ^ w1_t[2] ^ w0_t[0] ^ w3_t[2]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w3_t[2]);
    w3_t[3] = rotl32 ((w3_t[0] ^ w1_t[3] ^ w0_t[1] ^ w3_t[3]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w3_t[3]);

    COMPARE_M_SIMD (d, e, c, b);
  }
}

__kernel void m08100_m08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m08100_m16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m08100_s04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
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

  u32 salt_buf0[2];

  salt_buf0[0] = salt_bufs[salt_pos].salt_buf[0];
  salt_buf0[1] = salt_bufs[salt_pos].salt_buf[1];

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

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
   * reverse
   */

  const u32 e_rev = rotl32_S (search[1], 2u);

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

    append_0x80_4x4_VV (w0, w1, w2, w3, pw_len + 1);

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

    /**
     * prepend salt
     */

    const u32x pw_salt_len = pw_len + salt_len;

    u32x w0_t[4];
    u32x w1_t[4];
    u32x w2_t[4];
    u32x w3_t[4];

    w0_t[0] = salt_buf0[0];
    w0_t[1] = salt_buf0[1];
    w0_t[2] = w0[0];
    w0_t[3] = w0[1];
    w1_t[0] = w0[2];
    w1_t[1] = w0[3];
    w1_t[2] = w1[0];
    w1_t[3] = w1[1];
    w2_t[0] = w1[2];
    w2_t[1] = w1[3];
    w2_t[2] = w2[0];
    w2_t[3] = w2[1];
    w3_t[0] = w2[2];
    w3_t[1] = w2[3];
    w3_t[2] = 0;
    w3_t[3] = (pw_salt_len + 1) * 8;

    /**
     * sha1
     */

    u32x a = SHA1M_A;
    u32x b = SHA1M_B;
    u32x c = SHA1M_C;
    u32x d = SHA1M_D;
    u32x e = SHA1M_E;

    #undef K
    #define K SHA1C00

    SHA1_STEP (SHA1_F0o, a, b, c, d, e, w0_t[0]);
    SHA1_STEP (SHA1_F0o, e, a, b, c, d, w0_t[1]);
    SHA1_STEP (SHA1_F0o, d, e, a, b, c, w0_t[2]);
    SHA1_STEP (SHA1_F0o, c, d, e, a, b, w0_t[3]);
    SHA1_STEP (SHA1_F0o, b, c, d, e, a, w1_t[0]);
    SHA1_STEP (SHA1_F0o, a, b, c, d, e, w1_t[1]);
    SHA1_STEP (SHA1_F0o, e, a, b, c, d, w1_t[2]);
    SHA1_STEP (SHA1_F0o, d, e, a, b, c, w1_t[3]);
    SHA1_STEP (SHA1_F0o, c, d, e, a, b, w2_t[0]);
    SHA1_STEP (SHA1_F0o, b, c, d, e, a, w2_t[1]);
    SHA1_STEP (SHA1_F0o, a, b, c, d, e, w2_t[2]);
    SHA1_STEP (SHA1_F0o, e, a, b, c, d, w2_t[3]);
    SHA1_STEP (SHA1_F0o, d, e, a, b, c, w3_t[0]);
    SHA1_STEP (SHA1_F0o, c, d, e, a, b, w3_t[1]);
    SHA1_STEP (SHA1_F0o, b, c, d, e, a, w3_t[2]);
    SHA1_STEP (SHA1_F0o, a, b, c, d, e, w3_t[3]);
    w0_t[0] = rotl32 ((w3_t[1] ^ w2_t[0] ^ w0_t[2] ^ w0_t[0]), 1u); SHA1_STEP (SHA1_F0o, e, a, b, c, d, w0_t[0]);
    w0_t[1] = rotl32 ((w3_t[2] ^ w2_t[1] ^ w0_t[3] ^ w0_t[1]), 1u); SHA1_STEP (SHA1_F0o, d, e, a, b, c, w0_t[1]);
    w0_t[2] = rotl32 ((w3_t[3] ^ w2_t[2] ^ w1_t[0] ^ w0_t[2]), 1u); SHA1_STEP (SHA1_F0o, c, d, e, a, b, w0_t[2]);
    w0_t[3] = rotl32 ((w0_t[0] ^ w2_t[3] ^ w1_t[1] ^ w0_t[3]), 1u); SHA1_STEP (SHA1_F0o, b, c, d, e, a, w0_t[3]);

    #undef K
    #define K SHA1C01

    w1_t[0] = rotl32 ((w0_t[1] ^ w3_t[0] ^ w1_t[2] ^ w1_t[0]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w1_t[0]);
    w1_t[1] = rotl32 ((w0_t[2] ^ w3_t[1] ^ w1_t[3] ^ w1_t[1]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w1_t[1]);
    w1_t[2] = rotl32 ((w0_t[3] ^ w3_t[2] ^ w2_t[0] ^ w1_t[2]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w1_t[2]);
    w1_t[3] = rotl32 ((w1_t[0] ^ w3_t[3] ^ w2_t[1] ^ w1_t[3]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w1_t[3]);
    w2_t[0] = rotl32 ((w1_t[1] ^ w0_t[0] ^ w2_t[2] ^ w2_t[0]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w2_t[0]);
    w2_t[1] = rotl32 ((w1_t[2] ^ w0_t[1] ^ w2_t[3] ^ w2_t[1]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w2_t[1]);
    w2_t[2] = rotl32 ((w1_t[3] ^ w0_t[2] ^ w3_t[0] ^ w2_t[2]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w2_t[2]);
    w2_t[3] = rotl32 ((w2_t[0] ^ w0_t[3] ^ w3_t[1] ^ w2_t[3]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w2_t[3]);
    w3_t[0] = rotl32 ((w2_t[1] ^ w1_t[0] ^ w3_t[2] ^ w3_t[0]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w3_t[0]);
    w3_t[1] = rotl32 ((w2_t[2] ^ w1_t[1] ^ w3_t[3] ^ w3_t[1]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w3_t[1]);
    w3_t[2] = rotl32 ((w2_t[3] ^ w1_t[2] ^ w0_t[0] ^ w3_t[2]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w3_t[2]);
    w3_t[3] = rotl32 ((w3_t[0] ^ w1_t[3] ^ w0_t[1] ^ w3_t[3]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w3_t[3]);
    w0_t[0] = rotl32 ((w3_t[1] ^ w2_t[0] ^ w0_t[2] ^ w0_t[0]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w0_t[0]);
    w0_t[1] = rotl32 ((w3_t[2] ^ w2_t[1] ^ w0_t[3] ^ w0_t[1]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w0_t[1]);
    w0_t[2] = rotl32 ((w3_t[3] ^ w2_t[2] ^ w1_t[0] ^ w0_t[2]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w0_t[2]);
    w0_t[3] = rotl32 ((w0_t[0] ^ w2_t[3] ^ w1_t[1] ^ w0_t[3]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w0_t[3]);
    w1_t[0] = rotl32 ((w0_t[1] ^ w3_t[0] ^ w1_t[2] ^ w1_t[0]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w1_t[0]);
    w1_t[1] = rotl32 ((w0_t[2] ^ w3_t[1] ^ w1_t[3] ^ w1_t[1]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w1_t[1]);
    w1_t[2] = rotl32 ((w0_t[3] ^ w3_t[2] ^ w2_t[0] ^ w1_t[2]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w1_t[2]);
    w1_t[3] = rotl32 ((w1_t[0] ^ w3_t[3] ^ w2_t[1] ^ w1_t[3]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w1_t[3]);

    #undef K
    #define K SHA1C02

    w2_t[0] = rotl32 ((w1_t[1] ^ w0_t[0] ^ w2_t[2] ^ w2_t[0]), 1u); SHA1_STEP (SHA1_F2o, a, b, c, d, e, w2_t[0]);
    w2_t[1] = rotl32 ((w1_t[2] ^ w0_t[1] ^ w2_t[3] ^ w2_t[1]), 1u); SHA1_STEP (SHA1_F2o, e, a, b, c, d, w2_t[1]);
    w2_t[2] = rotl32 ((w1_t[3] ^ w0_t[2] ^ w3_t[0] ^ w2_t[2]), 1u); SHA1_STEP (SHA1_F2o, d, e, a, b, c, w2_t[2]);
    w2_t[3] = rotl32 ((w2_t[0] ^ w0_t[3] ^ w3_t[1] ^ w2_t[3]), 1u); SHA1_STEP (SHA1_F2o, c, d, e, a, b, w2_t[3]);
    w3_t[0] = rotl32 ((w2_t[1] ^ w1_t[0] ^ w3_t[2] ^ w3_t[0]), 1u); SHA1_STEP (SHA1_F2o, b, c, d, e, a, w3_t[0]);
    w3_t[1] = rotl32 ((w2_t[2] ^ w1_t[1] ^ w3_t[3] ^ w3_t[1]), 1u); SHA1_STEP (SHA1_F2o, a, b, c, d, e, w3_t[1]);
    w3_t[2] = rotl32 ((w2_t[3] ^ w1_t[2] ^ w0_t[0] ^ w3_t[2]), 1u); SHA1_STEP (SHA1_F2o, e, a, b, c, d, w3_t[2]);
    w3_t[3] = rotl32 ((w3_t[0] ^ w1_t[3] ^ w0_t[1] ^ w3_t[3]), 1u); SHA1_STEP (SHA1_F2o, d, e, a, b, c, w3_t[3]);
    w0_t[0] = rotl32 ((w3_t[1] ^ w2_t[0] ^ w0_t[2] ^ w0_t[0]), 1u); SHA1_STEP (SHA1_F2o, c, d, e, a, b, w0_t[0]);
    w0_t[1] = rotl32 ((w3_t[2] ^ w2_t[1] ^ w0_t[3] ^ w0_t[1]), 1u); SHA1_STEP (SHA1_F2o, b, c, d, e, a, w0_t[1]);
    w0_t[2] = rotl32 ((w3_t[3] ^ w2_t[2] ^ w1_t[0] ^ w0_t[2]), 1u); SHA1_STEP (SHA1_F2o, a, b, c, d, e, w0_t[2]);
    w0_t[3] = rotl32 ((w0_t[0] ^ w2_t[3] ^ w1_t[1] ^ w0_t[3]), 1u); SHA1_STEP (SHA1_F2o, e, a, b, c, d, w0_t[3]);
    w1_t[0] = rotl32 ((w0_t[1] ^ w3_t[0] ^ w1_t[2] ^ w1_t[0]), 1u); SHA1_STEP (SHA1_F2o, d, e, a, b, c, w1_t[0]);
    w1_t[1] = rotl32 ((w0_t[2] ^ w3_t[1] ^ w1_t[3] ^ w1_t[1]), 1u); SHA1_STEP (SHA1_F2o, c, d, e, a, b, w1_t[1]);
    w1_t[2] = rotl32 ((w0_t[3] ^ w3_t[2] ^ w2_t[0] ^ w1_t[2]), 1u); SHA1_STEP (SHA1_F2o, b, c, d, e, a, w1_t[2]);
    w1_t[3] = rotl32 ((w1_t[0] ^ w3_t[3] ^ w2_t[1] ^ w1_t[3]), 1u); SHA1_STEP (SHA1_F2o, a, b, c, d, e, w1_t[3]);
    w2_t[0] = rotl32 ((w1_t[1] ^ w0_t[0] ^ w2_t[2] ^ w2_t[0]), 1u); SHA1_STEP (SHA1_F2o, e, a, b, c, d, w2_t[0]);
    w2_t[1] = rotl32 ((w1_t[2] ^ w0_t[1] ^ w2_t[3] ^ w2_t[1]), 1u); SHA1_STEP (SHA1_F2o, d, e, a, b, c, w2_t[1]);
    w2_t[2] = rotl32 ((w1_t[3] ^ w0_t[2] ^ w3_t[0] ^ w2_t[2]), 1u); SHA1_STEP (SHA1_F2o, c, d, e, a, b, w2_t[2]);
    w2_t[3] = rotl32 ((w2_t[0] ^ w0_t[3] ^ w3_t[1] ^ w2_t[3]), 1u); SHA1_STEP (SHA1_F2o, b, c, d, e, a, w2_t[3]);

    #undef K
    #define K SHA1C03

    w3_t[0] = rotl32 ((w2_t[1] ^ w1_t[0] ^ w3_t[2] ^ w3_t[0]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w3_t[0]);
    w3_t[1] = rotl32 ((w2_t[2] ^ w1_t[1] ^ w3_t[3] ^ w3_t[1]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w3_t[1]);
    w3_t[2] = rotl32 ((w2_t[3] ^ w1_t[2] ^ w0_t[0] ^ w3_t[2]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w3_t[2]);
    w3_t[3] = rotl32 ((w3_t[0] ^ w1_t[3] ^ w0_t[1] ^ w3_t[3]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w3_t[3]);
    w0_t[0] = rotl32 ((w3_t[1] ^ w2_t[0] ^ w0_t[2] ^ w0_t[0]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w0_t[0]);
    w0_t[1] = rotl32 ((w3_t[2] ^ w2_t[1] ^ w0_t[3] ^ w0_t[1]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w0_t[1]);
    w0_t[2] = rotl32 ((w3_t[3] ^ w2_t[2] ^ w1_t[0] ^ w0_t[2]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w0_t[2]);
    w0_t[3] = rotl32 ((w0_t[0] ^ w2_t[3] ^ w1_t[1] ^ w0_t[3]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w0_t[3]);
    w1_t[0] = rotl32 ((w0_t[1] ^ w3_t[0] ^ w1_t[2] ^ w1_t[0]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w1_t[0]);
    w1_t[1] = rotl32 ((w0_t[2] ^ w3_t[1] ^ w1_t[3] ^ w1_t[1]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w1_t[1]);
    w1_t[2] = rotl32 ((w0_t[3] ^ w3_t[2] ^ w2_t[0] ^ w1_t[2]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w1_t[2]);
    w1_t[3] = rotl32 ((w1_t[0] ^ w3_t[3] ^ w2_t[1] ^ w1_t[3]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w1_t[3]);
    w2_t[0] = rotl32 ((w1_t[1] ^ w0_t[0] ^ w2_t[2] ^ w2_t[0]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w2_t[0]);
    w2_t[1] = rotl32 ((w1_t[2] ^ w0_t[1] ^ w2_t[3] ^ w2_t[1]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w2_t[1]);
    w2_t[2] = rotl32 ((w1_t[3] ^ w0_t[2] ^ w3_t[0] ^ w2_t[2]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w2_t[2]);
    w2_t[3] = rotl32 ((w2_t[0] ^ w0_t[3] ^ w3_t[1] ^ w2_t[3]), 1u); SHA1_STEP (SHA1_F1, a, b, c, d, e, w2_t[3]);

    if (MATCHES_NONE_VS (e, e_rev)) continue;

    w3_t[0] = rotl32 ((w2_t[1] ^ w1_t[0] ^ w3_t[2] ^ w3_t[0]), 1u); SHA1_STEP (SHA1_F1, e, a, b, c, d, w3_t[0]);
    w3_t[1] = rotl32 ((w2_t[2] ^ w1_t[1] ^ w3_t[3] ^ w3_t[1]), 1u); SHA1_STEP (SHA1_F1, d, e, a, b, c, w3_t[1]);
    w3_t[2] = rotl32 ((w2_t[3] ^ w1_t[2] ^ w0_t[0] ^ w3_t[2]), 1u); SHA1_STEP (SHA1_F1, c, d, e, a, b, w3_t[2]);
    w3_t[3] = rotl32 ((w3_t[0] ^ w1_t[3] ^ w0_t[1] ^ w3_t[3]), 1u); SHA1_STEP (SHA1_F1, b, c, d, e, a, w3_t[3]);

    COMPARE_S_SIMD (d, e, c, b);
  }
}

__kernel void m08100_s08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void m08100_s16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}
