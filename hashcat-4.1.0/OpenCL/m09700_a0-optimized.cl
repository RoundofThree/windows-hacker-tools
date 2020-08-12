/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//too much register pressure
//#define NEW_SIMD_CODE

#include "inc_vendor.cl"
#include "inc_hash_constants.h"
#include "inc_hash_functions.cl"
#include "inc_types.cl"
#include "inc_common.cl"
#include "inc_rp_optimized.h"
#include "inc_rp_optimized.cl"
#include "inc_simd.cl"
#include "inc_hash_md5.cl"

typedef struct
{
  u8 S[256];

  u32 wtf_its_faster;

} RC4_KEY;

DECLSPEC void swap (__local RC4_KEY *rc4_key, const u8 i, const u8 j)
{
  u8 tmp;

  tmp           = rc4_key->S[i];
  rc4_key->S[i] = rc4_key->S[j];
  rc4_key->S[j] = tmp;
}

DECLSPEC void rc4_init_16 (__local RC4_KEY *rc4_key, const u32 data[4])
{
  u32 v = 0x03020100;
  u32 a = 0x04040404;

  __local u32 *ptr = (__local u32 *) rc4_key->S;

  #ifdef _unroll
  #pragma unroll
  #endif
  for (u32 i = 0; i < 64; i++)
  {
    *ptr++ = v; v += a;
  }

  u32 j = 0;

  for (u32 i = 0; i < 16; i++)
  {
    u32 idx = i * 16;

    u32 v;

    v = data[0];

    j += rc4_key->S[idx] + (v >>  0); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >>  8); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >> 16); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >> 24); swap (rc4_key, idx, j); idx++;

    v = data[1];

    j += rc4_key->S[idx] + (v >>  0); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >>  8); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >> 16); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >> 24); swap (rc4_key, idx, j); idx++;

    v = data[2];

    j += rc4_key->S[idx] + (v >>  0); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >>  8); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >> 16); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >> 24); swap (rc4_key, idx, j); idx++;

    v = data[3];

    j += rc4_key->S[idx] + (v >>  0); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >>  8); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >> 16); swap (rc4_key, idx, j); idx++;
    j += rc4_key->S[idx] + (v >> 24); swap (rc4_key, idx, j); idx++;
  }
}

DECLSPEC u8 rc4_next_16 (__local RC4_KEY *rc4_key, u8 i, u8 j, const u32 in[4], u32 out[4])
{
  #ifdef _unroll
  #pragma unroll
  #endif
  for (u32 k = 0; k < 4; k++)
  {
    u32 xor4 = 0;

    u8 idx;

    i += 1;
    j += rc4_key->S[i];

    swap (rc4_key, i, j);

    idx = rc4_key->S[i] + rc4_key->S[j];

    xor4 |= rc4_key->S[idx] <<  0;

    i += 1;
    j += rc4_key->S[i];

    swap (rc4_key, i, j);

    idx = rc4_key->S[i] + rc4_key->S[j];

    xor4 |= rc4_key->S[idx] <<  8;

    i += 1;
    j += rc4_key->S[i];

    swap (rc4_key, i, j);

    idx = rc4_key->S[i] + rc4_key->S[j];

    xor4 |= rc4_key->S[idx] << 16;

    i += 1;
    j += rc4_key->S[i];

    swap (rc4_key, i, j);

    idx = rc4_key->S[i] + rc4_key->S[j];

    xor4 |= rc4_key->S[idx] << 24;

    out[k] = in[k] ^ xor4;
  }

  return j;
}

DECLSPEC void gen336 (u32 digest_pre[4], u32 salt_buf[4], u32 digest[4])
{
  u32 digest_t0[2];
  u32 digest_t1[2];
  u32 digest_t2[2];
  u32 digest_t3[2];

  digest_t0[0] = digest_pre[0];
  digest_t0[1] = digest_pre[1] & 0xff;

  digest_t1[0] =                       digest_pre[0] <<  8;
  digest_t1[1] = digest_pre[0] >> 24 | digest_pre[1] <<  8;

  digest_t2[0] =                       digest_pre[0] << 16;
  digest_t2[1] = digest_pre[0] >> 16 | digest_pre[1] << 16;

  digest_t3[0] =                       digest_pre[0] << 24;
  digest_t3[1] = digest_pre[0] >>  8 | digest_pre[1] << 24;

  u32 salt_buf_t0[4];
  u32 salt_buf_t1[5];
  u32 salt_buf_t2[5];
  u32 salt_buf_t3[5];

  salt_buf_t0[0] = salt_buf[0];
  salt_buf_t0[1] = salt_buf[1];
  salt_buf_t0[2] = salt_buf[2];
  salt_buf_t0[3] = salt_buf[3];

  salt_buf_t1[0] =                     salt_buf[0] <<  8;
  salt_buf_t1[1] = salt_buf[0] >> 24 | salt_buf[1] <<  8;
  salt_buf_t1[2] = salt_buf[1] >> 24 | salt_buf[2] <<  8;
  salt_buf_t1[3] = salt_buf[2] >> 24 | salt_buf[3] <<  8;
  salt_buf_t1[4] = salt_buf[3] >> 24;

  salt_buf_t2[0] =                     salt_buf[0] << 16;
  salt_buf_t2[1] = salt_buf[0] >> 16 | salt_buf[1] << 16;
  salt_buf_t2[2] = salt_buf[1] >> 16 | salt_buf[2] << 16;
  salt_buf_t2[3] = salt_buf[2] >> 16 | salt_buf[3] << 16;
  salt_buf_t2[4] = salt_buf[3] >> 16;

  salt_buf_t3[0] =                     salt_buf[0] << 24;
  salt_buf_t3[1] = salt_buf[0] >>  8 | salt_buf[1] << 24;
  salt_buf_t3[2] = salt_buf[1] >>  8 | salt_buf[2] << 24;
  salt_buf_t3[3] = salt_buf[2] >>  8 | salt_buf[3] << 24;
  salt_buf_t3[4] = salt_buf[3] >>  8;

  u32 w0_t[4];
  u32 w1_t[4];
  u32 w2_t[4];
  u32 w3_t[4];

  // generate the 16 * 21 buffer

  w0_t[0] = 0;
  w0_t[1] = 0;
  w0_t[2] = 0;
  w0_t[3] = 0;
  w1_t[0] = 0;
  w1_t[1] = 0;
  w1_t[2] = 0;
  w1_t[3] = 0;
  w2_t[0] = 0;
  w2_t[1] = 0;
  w2_t[2] = 0;
  w2_t[3] = 0;
  w3_t[0] = 0;
  w3_t[1] = 0;
  w3_t[2] = 0;
  w3_t[3] = 0;

  // 0..5
  w0_t[0]  = digest_t0[0];
  w0_t[1]  = digest_t0[1];

  // 5..21
  w0_t[1] |= salt_buf_t1[0];
  w0_t[2]  = salt_buf_t1[1];
  w0_t[3]  = salt_buf_t1[2];
  w1_t[0]  = salt_buf_t1[3];
  w1_t[1]  = salt_buf_t1[4];

  // 21..26
  w1_t[1] |= digest_t1[0];
  w1_t[2]  = digest_t1[1];

  // 26..42
  w1_t[2] |= salt_buf_t2[0];
  w1_t[3]  = salt_buf_t2[1];
  w2_t[0]  = salt_buf_t2[2];
  w2_t[1]  = salt_buf_t2[3];
  w2_t[2]  = salt_buf_t2[4];

  // 42..47
  w2_t[2] |= digest_t2[0];
  w2_t[3]  = digest_t2[1];

  // 47..63
  w2_t[3] |= salt_buf_t3[0];
  w3_t[0]  = salt_buf_t3[1];
  w3_t[1]  = salt_buf_t3[2];
  w3_t[2]  = salt_buf_t3[3];
  w3_t[3]  = salt_buf_t3[4];

  // 63..

  w3_t[3] |= digest_t3[0];

  md5_transform (w0_t, w1_t, w2_t, w3_t, digest);

  w0_t[0] = 0;
  w0_t[1] = 0;
  w0_t[2] = 0;
  w0_t[3] = 0;
  w1_t[0] = 0;
  w1_t[1] = 0;
  w1_t[2] = 0;
  w1_t[3] = 0;
  w2_t[0] = 0;
  w2_t[1] = 0;
  w2_t[2] = 0;
  w2_t[3] = 0;
  w3_t[0] = 0;
  w3_t[1] = 0;
  w3_t[2] = 0;
  w3_t[3] = 0;

  // 0..4
  w0_t[0]  = digest_t3[1];

  // 4..20
  w0_t[1]  = salt_buf_t0[0];
  w0_t[2]  = salt_buf_t0[1];
  w0_t[3]  = salt_buf_t0[2];
  w1_t[0]  = salt_buf_t0[3];

  // 20..25
  w1_t[1]  = digest_t0[0];
  w1_t[2]  = digest_t0[1];

  // 25..41
  w1_t[2] |= salt_buf_t1[0];
  w1_t[3]  = salt_buf_t1[1];
  w2_t[0]  = salt_buf_t1[2];
  w2_t[1]  = salt_buf_t1[3];
  w2_t[2]  = salt_buf_t1[4];

  // 41..46
  w2_t[2] |= digest_t1[0];
  w2_t[3]  = digest_t1[1];

  // 46..62
  w2_t[3] |= salt_buf_t2[0];
  w3_t[0]  = salt_buf_t2[1];
  w3_t[1]  = salt_buf_t2[2];
  w3_t[2]  = salt_buf_t2[3];
  w3_t[3]  = salt_buf_t2[4];

  // 62..
  w3_t[3] |= digest_t2[0];

  md5_transform (w0_t, w1_t, w2_t, w3_t, digest);

  w0_t[0] = 0;
  w0_t[1] = 0;
  w0_t[2] = 0;
  w0_t[3] = 0;
  w1_t[0] = 0;
  w1_t[1] = 0;
  w1_t[2] = 0;
  w1_t[3] = 0;
  w2_t[0] = 0;
  w2_t[1] = 0;
  w2_t[2] = 0;
  w2_t[3] = 0;
  w3_t[0] = 0;
  w3_t[1] = 0;
  w3_t[2] = 0;
  w3_t[3] = 0;

  // 0..3
  w0_t[0]  = digest_t2[1];

  // 3..19
  w0_t[0] |= salt_buf_t3[0];
  w0_t[1]  = salt_buf_t3[1];
  w0_t[2]  = salt_buf_t3[2];
  w0_t[3]  = salt_buf_t3[3];
  w1_t[0]  = salt_buf_t3[4];

  // 19..24
  w1_t[0] |= digest_t3[0];
  w1_t[1]  = digest_t3[1];

  // 24..40
  w1_t[2]  = salt_buf_t0[0];
  w1_t[3]  = salt_buf_t0[1];
  w2_t[0]  = salt_buf_t0[2];
  w2_t[1]  = salt_buf_t0[3];

  // 40..45
  w2_t[2]  = digest_t0[0];
  w2_t[3]  = digest_t0[1];

  // 45..61
  w2_t[3] |= salt_buf_t1[0];
  w3_t[0]  = salt_buf_t1[1];
  w3_t[1]  = salt_buf_t1[2];
  w3_t[2]  = salt_buf_t1[3];
  w3_t[3]  = salt_buf_t1[4];

  // 61..
  w3_t[3] |= digest_t1[0];

  md5_transform (w0_t, w1_t, w2_t, w3_t, digest);

  w0_t[0] = 0;
  w0_t[1] = 0;
  w0_t[2] = 0;
  w0_t[3] = 0;
  w1_t[0] = 0;
  w1_t[1] = 0;
  w1_t[2] = 0;
  w1_t[3] = 0;
  w2_t[0] = 0;
  w2_t[1] = 0;
  w2_t[2] = 0;
  w2_t[3] = 0;
  w3_t[0] = 0;
  w3_t[1] = 0;
  w3_t[2] = 0;
  w3_t[3] = 0;

  // 0..2
  w0_t[0]  = digest_t1[1];

  // 2..18
  w0_t[0] |= salt_buf_t2[0];
  w0_t[1]  = salt_buf_t2[1];
  w0_t[2]  = salt_buf_t2[2];
  w0_t[3]  = salt_buf_t2[3];
  w1_t[0]  = salt_buf_t2[4];

  // 18..23
  w1_t[0] |= digest_t2[0];
  w1_t[1]  = digest_t2[1];

  // 23..39
  w1_t[1] |= salt_buf_t3[0];
  w1_t[2]  = salt_buf_t3[1];
  w1_t[3]  = salt_buf_t3[2];
  w2_t[0]  = salt_buf_t3[3];
  w2_t[1]  = salt_buf_t3[4];

  // 39..44
  w2_t[1] |= digest_t3[0];
  w2_t[2]  = digest_t3[1];

  // 44..60
  w2_t[3]  = salt_buf_t0[0];
  w3_t[0]  = salt_buf_t0[1];
  w3_t[1]  = salt_buf_t0[2];
  w3_t[2]  = salt_buf_t0[3];

  // 60..
  w3_t[3]  = digest_t0[0];

  md5_transform (w0_t, w1_t, w2_t, w3_t, digest);

  w0_t[0] = 0;
  w0_t[1] = 0;
  w0_t[2] = 0;
  w0_t[3] = 0;
  w1_t[0] = 0;
  w1_t[1] = 0;
  w1_t[2] = 0;
  w1_t[3] = 0;
  w2_t[0] = 0;
  w2_t[1] = 0;
  w2_t[2] = 0;
  w2_t[3] = 0;
  w3_t[0] = 0;
  w3_t[1] = 0;
  w3_t[2] = 0;
  w3_t[3] = 0;

  // 0..1
  w0_t[0]  = digest_t0[1];

  // 1..17
  w0_t[0] |= salt_buf_t1[0];
  w0_t[1]  = salt_buf_t1[1];
  w0_t[2]  = salt_buf_t1[2];
  w0_t[3]  = salt_buf_t1[3];
  w1_t[0]  = salt_buf_t1[4];

  // 17..22
  w1_t[0] |= digest_t1[0];
  w1_t[1]  = digest_t1[1];

  // 22..38
  w1_t[1] |= salt_buf_t2[0];
  w1_t[2]  = salt_buf_t2[1];
  w1_t[3]  = salt_buf_t2[2];
  w2_t[0]  = salt_buf_t2[3];
  w2_t[1]  = salt_buf_t2[4];

  // 38..43
  w2_t[1] |= digest_t2[0];
  w2_t[2]  = digest_t2[1];

  // 43..59
  w2_t[2] |= salt_buf_t3[0];
  w2_t[3]  = salt_buf_t3[1];
  w3_t[0]  = salt_buf_t3[2];
  w3_t[1]  = salt_buf_t3[3];
  w3_t[2]  = salt_buf_t3[4];

  // 59..
  w3_t[2] |= digest_t3[0];
  w3_t[3]  = digest_t3[1];

  md5_transform (w0_t, w1_t, w2_t, w3_t, digest);

  w0_t[0]  = salt_buf_t0[0];
  w0_t[1]  = salt_buf_t0[1];
  w0_t[2]  = salt_buf_t0[2];
  w0_t[3]  = salt_buf_t0[3];
  w1_t[0]  = 0x80;
  w1_t[1]  = 0;
  w1_t[2]  = 0;
  w1_t[3]  = 0;
  w2_t[0]  = 0;
  w2_t[1]  = 0;
  w2_t[2]  = 0;
  w2_t[3]  = 0;
  w3_t[0]  = 0;
  w3_t[1]  = 0;
  w3_t[2]  = 21 * 16 * 8;
  w3_t[3]  = 0;

  md5_transform (w0_t, w1_t, w2_t, w3_t, digest);
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m09700_m04 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global oldoffice01_t *oldoffice01_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
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

  pw_buf0[0] = pws[gid].i[ 0];
  pw_buf0[1] = pws[gid].i[ 1];
  pw_buf0[2] = pws[gid].i[ 2];
  pw_buf0[3] = pws[gid].i[ 3];
  pw_buf1[0] = pws[gid].i[ 4];
  pw_buf1[1] = pws[gid].i[ 5];
  pw_buf1[2] = pws[gid].i[ 6];
  pw_buf1[3] = pws[gid].i[ 7];

  const u32 pw_len = pws[gid].pw_len;

  /**
   * shared
   */

  __local RC4_KEY rc4_keys[64];

  __local RC4_KEY *rc4_key = &rc4_keys[lid];

  /**
   * salt
   */

  u32 salt_buf[4];

  salt_buf[0] = salt_bufs[salt_pos].salt_buf[0];
  salt_buf[1] = salt_bufs[salt_pos].salt_buf[1];
  salt_buf[2] = salt_bufs[salt_pos].salt_buf[2];
  salt_buf[3] = salt_bufs[salt_pos].salt_buf[3];

  /**
   * esalt
   */

  const u32 version = oldoffice01_bufs[digests_offset].version;

  u32 encryptedVerifier[4];

  encryptedVerifier[0] = oldoffice01_bufs[digests_offset].encryptedVerifier[0];
  encryptedVerifier[1] = oldoffice01_bufs[digests_offset].encryptedVerifier[1];
  encryptedVerifier[2] = oldoffice01_bufs[digests_offset].encryptedVerifier[2];
  encryptedVerifier[3] = oldoffice01_bufs[digests_offset].encryptedVerifier[3];

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    u32x w0[4] = { 0 };
    u32x w1[4] = { 0 };
    u32x w2[4] = { 0 };
    u32x w3[4] = { 0 };

    const u32x out_len = apply_rules_vect (pw_buf0, pw_buf1, pw_len, rules_buf, il_pos, w0, w1);

    append_0x80_2x4_VV (w0, w1, out_len);

    /**
     * md5
     */

    make_utf16le (w1, w2, w3);
    make_utf16le (w0, w0, w1);

    w3[2] = out_len * 8 * 2;
    w3[3] = 0;

    u32 digest_pre[4];

    digest_pre[0] = MD5M_A;
    digest_pre[1] = MD5M_B;
    digest_pre[2] = MD5M_C;
    digest_pre[3] = MD5M_D;

    md5_transform (w0, w1, w2, w3, digest_pre);

    digest_pre[0] &= 0xffffffff;
    digest_pre[1] &= 0x000000ff;
    digest_pre[2] &= 0x00000000;
    digest_pre[3] &= 0x00000000;

    u32 digest[4];

    digest[0] = MD5M_A;
    digest[1] = MD5M_B;
    digest[2] = MD5M_C;
    digest[3] = MD5M_D;

    gen336 (digest_pre, salt_buf, digest);

    // now the 40 bit input for the MD5 which then will generate the RC4 key, so it's precomputable!

    w0[0]  = digest[0];
    w0[1]  = digest[1] & 0xff;
    w0[2]  = 0x8000;
    w0[3]  = 0;
    w1[0]  = 0;
    w1[1]  = 0;
    w1[2]  = 0;
    w1[3]  = 0;
    w2[0]  = 0;
    w2[1]  = 0;
    w2[2]  = 0;
    w2[3]  = 0;
    w3[0]  = 0;
    w3[1]  = 0;
    w3[2]  = 9 * 8;
    w3[3]  = 0;

    digest[0] = MD5M_A;
    digest[1] = MD5M_B;
    digest[2] = MD5M_C;
    digest[3] = MD5M_D;

    md5_transform (w0, w1, w2, w3, digest);

    // now the RC4 part

    u32 key[4];

    key[0] = digest[0];
    key[1] = digest[1];
    key[2] = digest[2];
    key[3] = digest[3];

    rc4_init_16 (rc4_key, key);

    u32 out[4];

    u8 j = rc4_next_16 (rc4_key, 0, 0, encryptedVerifier, out);

    w0[0] = out[0];
    w0[1] = out[1];
    w0[2] = out[2];
    w0[3] = out[3];
    w1[0] = 0x80;
    w1[1] = 0;
    w1[2] = 0;
    w1[3] = 0;
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 16 * 8;
    w3[3] = 0;

    digest[0] = MD5M_A;
    digest[1] = MD5M_B;
    digest[2] = MD5M_C;
    digest[3] = MD5M_D;

    md5_transform (w0, w1, w2, w3, digest);

    rc4_next_16 (rc4_key, 16, j, digest, out);

    COMPARE_M_SIMD (out[0], out[1], out[2], out[3]);
  }
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m09700_m08 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global oldoffice01_t *oldoffice01_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m09700_m16 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global oldoffice01_t *oldoffice01_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m09700_s04 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global oldoffice01_t *oldoffice01_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
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

  pw_buf0[0] = pws[gid].i[ 0];
  pw_buf0[1] = pws[gid].i[ 1];
  pw_buf0[2] = pws[gid].i[ 2];
  pw_buf0[3] = pws[gid].i[ 3];
  pw_buf1[0] = pws[gid].i[ 4];
  pw_buf1[1] = pws[gid].i[ 5];
  pw_buf1[2] = pws[gid].i[ 6];
  pw_buf1[3] = pws[gid].i[ 7];

  const u32 pw_len = pws[gid].pw_len;

  /**
   * shared
   */

  __local RC4_KEY rc4_keys[64];

  __local RC4_KEY *rc4_key = &rc4_keys[lid];

  /**
   * salt
   */

  u32 salt_buf[4];

  salt_buf[0] = salt_bufs[salt_pos].salt_buf[0];
  salt_buf[1] = salt_bufs[salt_pos].salt_buf[1];
  salt_buf[2] = salt_bufs[salt_pos].salt_buf[2];
  salt_buf[3] = salt_bufs[salt_pos].salt_buf[3];

  /**
   * esalt
   */

  const u32 version = oldoffice01_bufs[digests_offset].version;

  u32 encryptedVerifier[4];

  encryptedVerifier[0] = oldoffice01_bufs[digests_offset].encryptedVerifier[0];
  encryptedVerifier[1] = oldoffice01_bufs[digests_offset].encryptedVerifier[1];
  encryptedVerifier[2] = oldoffice01_bufs[digests_offset].encryptedVerifier[2];
  encryptedVerifier[3] = oldoffice01_bufs[digests_offset].encryptedVerifier[3];

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

    const u32x out_len = apply_rules_vect (pw_buf0, pw_buf1, pw_len, rules_buf, il_pos, w0, w1);

    append_0x80_2x4_VV (w0, w1, out_len);

    /**
     * md5
     */

    make_utf16le (w1, w2, w3);
    make_utf16le (w0, w0, w1);

    w3[2] = out_len * 8 * 2;
    w3[3] = 0;

    u32 digest_pre[4];

    digest_pre[0] = MD5M_A;
    digest_pre[1] = MD5M_B;
    digest_pre[2] = MD5M_C;
    digest_pre[3] = MD5M_D;

    md5_transform (w0, w1, w2, w3, digest_pre);

    digest_pre[0] &= 0xffffffff;
    digest_pre[1] &= 0x000000ff;
    digest_pre[2] &= 0x00000000;
    digest_pre[3] &= 0x00000000;

    u32 digest[4];

    digest[0] = MD5M_A;
    digest[1] = MD5M_B;
    digest[2] = MD5M_C;
    digest[3] = MD5M_D;

    gen336 (digest_pre, salt_buf, digest);

    // now the 40 bit input for the MD5 which then will generate the RC4 key, so it's precomputable!

    w0[0]  = digest[0];
    w0[1]  = digest[1] & 0xff;
    w0[2]  = 0x8000;
    w0[3]  = 0;
    w1[0]  = 0;
    w1[1]  = 0;
    w1[2]  = 0;
    w1[3]  = 0;
    w2[0]  = 0;
    w2[1]  = 0;
    w2[2]  = 0;
    w2[3]  = 0;
    w3[0]  = 0;
    w3[1]  = 0;
    w3[2]  = 9 * 8;
    w3[3]  = 0;

    digest[0] = MD5M_A;
    digest[1] = MD5M_B;
    digest[2] = MD5M_C;
    digest[3] = MD5M_D;

    md5_transform (w0, w1, w2, w3, digest);

    // now the RC4 part

    u32 key[4];

    key[0] = digest[0];
    key[1] = digest[1];
    key[2] = digest[2];
    key[3] = digest[3];

    rc4_init_16 (rc4_key, key);

    u32 out[4];

    u8 j = rc4_next_16 (rc4_key, 0, 0, encryptedVerifier, out);

    w0[0] = out[0];
    w0[1] = out[1];
    w0[2] = out[2];
    w0[3] = out[3];
    w1[0] = 0x80;
    w1[1] = 0;
    w1[2] = 0;
    w1[3] = 0;
    w2[0] = 0;
    w2[1] = 0;
    w2[2] = 0;
    w2[3] = 0;
    w3[0] = 0;
    w3[1] = 0;
    w3[2] = 16 * 8;
    w3[3] = 0;

    digest[0] = MD5M_A;
    digest[1] = MD5M_B;
    digest[2] = MD5M_C;
    digest[3] = MD5M_D;

    md5_transform (w0, w1, w2, w3, digest);

    rc4_next_16 (rc4_key, 16, j, digest, out);

    COMPARE_S_SIMD (out[0], out[1], out[2], out[3]);
  }
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m09700_s08 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global oldoffice01_t *oldoffice01_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m09700_s16 (__global pw_t *pws, __constant const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global oldoffice01_t *oldoffice01_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}
