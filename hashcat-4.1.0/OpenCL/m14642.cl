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
#include "inc_hash_ripemd160.cl"
#include "inc_cipher_serpent.cl"

#include "inc_luks_af.cl"
#include "inc_luks_essiv.cl"
#include "inc_luks_xts.cl"

#include "inc_luks_serpent.cl"

#define COMPARE_S "inc_comp_single.cl"
#define COMPARE_M "inc_comp_multi.cl"

#define MAX_ENTROPY 7.0

DECLSPEC void hmac_ripemd160_run_V (u32x w0[4], u32x w1[4], u32x w2[4], u32x w3[4], u32x ipad[5], u32x opad[5], u32x digest[5])
{
  digest[0] = ipad[0];
  digest[1] = ipad[1];
  digest[2] = ipad[2];
  digest[3] = ipad[3];
  digest[4] = ipad[4];

  ripemd160_transform_vector (w0, w1, w2, w3, digest);

  w0[0] = digest[0];
  w0[1] = digest[1];
  w0[2] = digest[2];
  w0[3] = digest[3];
  w1[0] = digest[4];
  w1[1] = 0x80;
  w1[2] = 0;
  w1[3] = 0;
  w2[0] = 0;
  w2[1] = 0;
  w2[2] = 0;
  w2[3] = 0;
  w3[0] = 0;
  w3[1] = 0;
  w3[2] = (64 + 20) * 8;
  w3[3] = 0;

  digest[0] = opad[0];
  digest[1] = opad[1];
  digest[2] = opad[2];
  digest[3] = opad[3];
  digest[4] = opad[4];

  ripemd160_transform_vector (w0, w1, w2, w3, digest);
}

__kernel void m14642_init (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global luks_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const luks_t *luks_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  ripemd160_hmac_ctx_t ripemd160_hmac_ctx;

  ripemd160_hmac_init_global (&ripemd160_hmac_ctx, pws[gid].i, pws[gid].pw_len);

  tmps[gid].ipad32[0] = ripemd160_hmac_ctx.ipad.h[0];
  tmps[gid].ipad32[1] = ripemd160_hmac_ctx.ipad.h[1];
  tmps[gid].ipad32[2] = ripemd160_hmac_ctx.ipad.h[2];
  tmps[gid].ipad32[3] = ripemd160_hmac_ctx.ipad.h[3];
  tmps[gid].ipad32[4] = ripemd160_hmac_ctx.ipad.h[4];

  tmps[gid].opad32[0] = ripemd160_hmac_ctx.opad.h[0];
  tmps[gid].opad32[1] = ripemd160_hmac_ctx.opad.h[1];
  tmps[gid].opad32[2] = ripemd160_hmac_ctx.opad.h[2];
  tmps[gid].opad32[3] = ripemd160_hmac_ctx.opad.h[3];
  tmps[gid].opad32[4] = ripemd160_hmac_ctx.opad.h[4];

  ripemd160_hmac_update_global (&ripemd160_hmac_ctx, salt_bufs[salt_pos].salt_buf, salt_bufs[salt_pos].salt_len);

  const u32 key_size = luks_bufs[digests_offset].key_size;

  for (u32 i = 0, j = 1; i < ((key_size / 8) / 4); i += 5, j += 1)
  {
    ripemd160_hmac_ctx_t ripemd160_hmac_ctx2 = ripemd160_hmac_ctx;

    u32 w0[4];
    u32 w1[4];
    u32 w2[4];
    u32 w3[4];

    w0[0] = j << 24;
    w0[1] = 0;
    w0[2] = 0;
    w0[3] = 0;
    w1[0] = 0;
    w1[1] = 0;
    w1[2] = 0;
    w1[3] = 0;
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 0;
    w3[3] = 0;

    ripemd160_hmac_update_64 (&ripemd160_hmac_ctx2, w0, w1, w2, w3, 4);

    ripemd160_hmac_final (&ripemd160_hmac_ctx2);

    tmps[gid].dgst32[i + 0] = ripemd160_hmac_ctx2.opad.h[0];
    tmps[gid].dgst32[i + 1] = ripemd160_hmac_ctx2.opad.h[1];
    tmps[gid].dgst32[i + 2] = ripemd160_hmac_ctx2.opad.h[2];
    tmps[gid].dgst32[i + 3] = ripemd160_hmac_ctx2.opad.h[3];
    tmps[gid].dgst32[i + 4] = ripemd160_hmac_ctx2.opad.h[4];

    tmps[gid].out32[i + 0] = tmps[gid].dgst32[i + 0];
    tmps[gid].out32[i + 1] = tmps[gid].dgst32[i + 1];
    tmps[gid].out32[i + 2] = tmps[gid].dgst32[i + 2];
    tmps[gid].out32[i + 3] = tmps[gid].dgst32[i + 3];
    tmps[gid].out32[i + 4] = tmps[gid].dgst32[i + 4];
  }
}

__kernel void m14642_loop (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global luks_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const luks_t *luks_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  const u64 gid = get_global_id (0);

  if ((gid * VECT_SIZE) >= gid_max) return;

  u32x ipad[5];
  u32x opad[5];

  ipad[0] = packv (tmps, ipad32, gid, 0);
  ipad[1] = packv (tmps, ipad32, gid, 1);
  ipad[2] = packv (tmps, ipad32, gid, 2);
  ipad[3] = packv (tmps, ipad32, gid, 3);
  ipad[4] = packv (tmps, ipad32, gid, 4);

  opad[0] = packv (tmps, opad32, gid, 0);
  opad[1] = packv (tmps, opad32, gid, 1);
  opad[2] = packv (tmps, opad32, gid, 2);
  opad[3] = packv (tmps, opad32, gid, 3);
  opad[4] = packv (tmps, opad32, gid, 4);

  u32 key_size = luks_bufs[digests_offset].key_size;

  for (u32 i = 0; i < ((key_size / 8) / 4); i += 5)
  {
    u32x dgst[5];
    u32x out[5];

    dgst[0] = packv (tmps, dgst32, gid, i + 0);
    dgst[1] = packv (tmps, dgst32, gid, i + 1);
    dgst[2] = packv (tmps, dgst32, gid, i + 2);
    dgst[3] = packv (tmps, dgst32, gid, i + 3);
    dgst[4] = packv (tmps, dgst32, gid, i + 4);

    out[0] = packv (tmps, out32, gid, i + 0);
    out[1] = packv (tmps, out32, gid, i + 1);
    out[2] = packv (tmps, out32, gid, i + 2);
    out[3] = packv (tmps, out32, gid, i + 3);
    out[4] = packv (tmps, out32, gid, i + 4);

    for (u32 j = 0; j < loop_cnt; j++)
    {
      u32x w0[4];
      u32x w1[4];
      u32x w2[4];
      u32x w3[4];

      w0[0] = dgst[0];
      w0[1] = dgst[1];
      w0[2] = dgst[2];
      w0[3] = dgst[3];
      w1[0] = dgst[4];
      w1[1] = 0x80;
      w1[2] = 0;
      w1[3] = 0;
      w2[0] = 0;
      w2[1] = 0;
      w2[2] = 0;
      w2[3] = 0;
      w3[0] = 0;
      w3[1] = 0;
      w3[2] = (64 + 20) * 8;
      w3[3] = 0;

      hmac_ripemd160_run_V (w0, w1, w2, w3, ipad, opad, dgst);

      out[0] ^= dgst[0];
      out[1] ^= dgst[1];
      out[2] ^= dgst[2];
      out[3] ^= dgst[3];
      out[4] ^= dgst[4];
    }

    unpackv (tmps, dgst32, gid, i + 0, dgst[0]);
    unpackv (tmps, dgst32, gid, i + 1, dgst[1]);
    unpackv (tmps, dgst32, gid, i + 2, dgst[2]);
    unpackv (tmps, dgst32, gid, i + 3, dgst[3]);
    unpackv (tmps, dgst32, gid, i + 4, dgst[4]);

    unpackv (tmps, out32, gid, i + 0, out[0]);
    unpackv (tmps, out32, gid, i + 1, out[1]);
    unpackv (tmps, out32, gid, i + 2, out[2]);
    unpackv (tmps, out32, gid, i + 3, out[3]);
    unpackv (tmps, out32, gid, i + 4, out[4]);
  }
}

__kernel void m14642_comp (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global luks_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const luks_t *luks_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  // decrypt AF with first pbkdf2 result
  // merge AF to masterkey
  // decrypt first payload sector with masterkey

  u32 pt_buf[128];

  luks_af_ripemd160_then_serpent_decrypt (&luks_bufs[digests_offset], &tmps[gid], pt_buf);

  // check entropy

  const float entropy = get_entropy (pt_buf, 128);

  if (entropy < MAX_ENTROPY)
  {
    if (atomic_inc (&hashes_shown[digests_offset]) == 0)
    {
      mark_hash (plains_buf, d_return_buf, salt_pos, digests_cnt, 0, 0, gid, 0);
    }
  }
}
