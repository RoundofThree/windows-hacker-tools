/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#include "inc_vendor.cl"
#include "inc_hash_constants.h"
#include "inc_hash_functions.cl"
#include "inc_types.cl"
#include "inc_common.cl"
#include "inc_hash_sha512.cl"

#define COMPARE_S "inc_comp_single.cl"
#define COMPARE_M "inc_comp_multi.cl"

__kernel void m07900_init (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global drupal7_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  sha512_ctx_t ctx;

  sha512_init (&ctx);

  sha512_update_global_swap (&ctx, salt_bufs[salt_pos].salt_buf, salt_bufs[salt_pos].salt_len);

  sha512_update_global_swap (&ctx, pws[gid].i, pws[gid].pw_len);

  sha512_final (&ctx);

  tmps[gid].digest_buf[0] = ctx.h[0];
  tmps[gid].digest_buf[1] = ctx.h[1];
  tmps[gid].digest_buf[2] = ctx.h[2];
  tmps[gid].digest_buf[3] = ctx.h[3];
  tmps[gid].digest_buf[4] = ctx.h[4];
  tmps[gid].digest_buf[5] = ctx.h[5];
  tmps[gid].digest_buf[6] = ctx.h[6];
  tmps[gid].digest_buf[7] = ctx.h[7];
}

__kernel void m07900_loop (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global drupal7_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * init
   */

  const u32 pw_len = pws[gid].pw_len;

  u32 w[64] = { 0 };

  for (int i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  for (int i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = swap32_S (w[idx]);
  }

  /**
   * load
   */

  u64 digest[8];

  digest[0] = tmps[gid].digest_buf[0];
  digest[1] = tmps[gid].digest_buf[1];
  digest[2] = tmps[gid].digest_buf[2];
  digest[3] = tmps[gid].digest_buf[3];
  digest[4] = tmps[gid].digest_buf[4];
  digest[5] = tmps[gid].digest_buf[5];
  digest[6] = tmps[gid].digest_buf[6];
  digest[7] = tmps[gid].digest_buf[7];

  /**
   * loop
   */

  sha512_ctx_t sha512_ctx;

  sha512_init (&sha512_ctx);

  sha512_ctx.w0[0] = h32_from_64_S (digest[0]);
  sha512_ctx.w0[1] = l32_from_64_S (digest[0]);
  sha512_ctx.w0[2] = h32_from_64_S (digest[1]);
  sha512_ctx.w0[3] = l32_from_64_S (digest[1]);
  sha512_ctx.w1[0] = h32_from_64_S (digest[2]);
  sha512_ctx.w1[1] = l32_from_64_S (digest[2]);
  sha512_ctx.w1[2] = h32_from_64_S (digest[3]);
  sha512_ctx.w1[3] = l32_from_64_S (digest[3]);
  sha512_ctx.w2[0] = h32_from_64_S (digest[4]);
  sha512_ctx.w2[1] = l32_from_64_S (digest[4]);
  sha512_ctx.w2[2] = h32_from_64_S (digest[5]);
  sha512_ctx.w2[3] = l32_from_64_S (digest[5]);
  sha512_ctx.w3[0] = h32_from_64_S (digest[6]);
  sha512_ctx.w3[1] = l32_from_64_S (digest[6]);
  sha512_ctx.w3[2] = h32_from_64_S (digest[7]);
  sha512_ctx.w3[3] = l32_from_64_S (digest[7]);

  sha512_ctx.len = 64;

  sha512_update (&sha512_ctx, w, pw_len);

  sha512_final (&sha512_ctx);

  digest[0] = sha512_ctx.h[0];
  digest[1] = sha512_ctx.h[1];
  digest[2] = sha512_ctx.h[2];
  digest[3] = sha512_ctx.h[3];
  digest[4] = sha512_ctx.h[4];
  digest[5] = sha512_ctx.h[5];
  digest[6] = sha512_ctx.h[6];
  digest[7] = sha512_ctx.h[7];

  if ((64 + pw_len + 1) >= 112)
  {
    for (u32 i = 1; i < loop_cnt; i++)
    {
      sha512_init (&sha512_ctx);

      sha512_ctx.w0[0] = h32_from_64_S (digest[0]);
      sha512_ctx.w0[1] = l32_from_64_S (digest[0]);
      sha512_ctx.w0[2] = h32_from_64_S (digest[1]);
      sha512_ctx.w0[3] = l32_from_64_S (digest[1]);
      sha512_ctx.w1[0] = h32_from_64_S (digest[2]);
      sha512_ctx.w1[1] = l32_from_64_S (digest[2]);
      sha512_ctx.w1[2] = h32_from_64_S (digest[3]);
      sha512_ctx.w1[3] = l32_from_64_S (digest[3]);
      sha512_ctx.w2[0] = h32_from_64_S (digest[4]);
      sha512_ctx.w2[1] = l32_from_64_S (digest[4]);
      sha512_ctx.w2[2] = h32_from_64_S (digest[5]);
      sha512_ctx.w2[3] = l32_from_64_S (digest[5]);
      sha512_ctx.w3[0] = h32_from_64_S (digest[6]);
      sha512_ctx.w3[1] = l32_from_64_S (digest[6]);
      sha512_ctx.w3[2] = h32_from_64_S (digest[7]);
      sha512_ctx.w3[3] = l32_from_64_S (digest[7]);

      sha512_ctx.len = 64;

      sha512_update (&sha512_ctx, w, pw_len);

      sha512_final (&sha512_ctx);

      digest[0] = sha512_ctx.h[0];
      digest[1] = sha512_ctx.h[1];
      digest[2] = sha512_ctx.h[2];
      digest[3] = sha512_ctx.h[3];
      digest[4] = sha512_ctx.h[4];
      digest[5] = sha512_ctx.h[5];
      digest[6] = sha512_ctx.h[6];
      digest[7] = sha512_ctx.h[7];
    }
  }
  else
  {
    for (u32 i = 1; i < loop_cnt; i++)
    {
      sha512_ctx.w0[0] = h32_from_64_S (digest[0]);
      sha512_ctx.w0[1] = l32_from_64_S (digest[0]);
      sha512_ctx.w0[2] = h32_from_64_S (digest[1]);
      sha512_ctx.w0[3] = l32_from_64_S (digest[1]);
      sha512_ctx.w1[0] = h32_from_64_S (digest[2]);
      sha512_ctx.w1[1] = l32_from_64_S (digest[2]);
      sha512_ctx.w1[2] = h32_from_64_S (digest[3]);
      sha512_ctx.w1[3] = l32_from_64_S (digest[3]);
      sha512_ctx.w2[0] = h32_from_64_S (digest[4]);
      sha512_ctx.w2[1] = l32_from_64_S (digest[4]);
      sha512_ctx.w2[2] = h32_from_64_S (digest[5]);
      sha512_ctx.w2[3] = l32_from_64_S (digest[5]);
      sha512_ctx.w3[0] = h32_from_64_S (digest[6]);
      sha512_ctx.w3[1] = l32_from_64_S (digest[6]);
      sha512_ctx.w3[2] = h32_from_64_S (digest[7]);
      sha512_ctx.w3[3] = l32_from_64_S (digest[7]);

      digest[0] = SHA512M_A;
      digest[1] = SHA512M_B;
      digest[2] = SHA512M_C;
      digest[3] = SHA512M_D;
      digest[4] = SHA512M_E;
      digest[5] = SHA512M_F;
      digest[6] = SHA512M_G;
      digest[7] = SHA512M_H;

      sha512_transform (sha512_ctx.w0, sha512_ctx.w1, sha512_ctx.w2, sha512_ctx.w3, sha512_ctx.w4, sha512_ctx.w5, sha512_ctx.w6, sha512_ctx.w7, digest);
    }
  }

  tmps[gid].digest_buf[0] = digest[0];
  tmps[gid].digest_buf[1] = digest[1];
  tmps[gid].digest_buf[2] = digest[2];
  tmps[gid].digest_buf[3] = digest[3];
  tmps[gid].digest_buf[4] = digest[4];
  tmps[gid].digest_buf[5] = digest[5];
  tmps[gid].digest_buf[6] = digest[6];
  tmps[gid].digest_buf[7] = digest[7];
}

__kernel void m07900_comp (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global drupal7_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  const u64 lid = get_local_id (0);

  /**
   * digest
   */

  const u32 r0 = l32_from_64_S (tmps[gid].digest_buf[0]);
  const u32 r1 = h32_from_64_S (tmps[gid].digest_buf[0]);
  const u32 r2 = l32_from_64_S (tmps[gid].digest_buf[1]);
  const u32 r3 = h32_from_64_S (tmps[gid].digest_buf[1]);

  #define il_pos 0

  #include COMPARE_M
}
