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
#include "inc_simd.cl"
#include "inc_hash_md4.cl"
#include "inc_hash_md5.cl"

typedef struct
{
  u8 S[256];

  u32 wtf_its_faster;

} RC4_KEY;

DECLSPEC void swap (SCR_TYPE RC4_KEY *rc4_key, const u8 i, const u8 j)
{
  u8 tmp;

  tmp           = rc4_key->S[i];
  rc4_key->S[i] = rc4_key->S[j];
  rc4_key->S[j] = tmp;
}

DECLSPEC void rc4_init_16 (SCR_TYPE RC4_KEY *rc4_key, const u32 data[4])
{
  u32 v = 0x03020100;
  u32 a = 0x04040404;

  SCR_TYPE u32 *ptr = (SCR_TYPE u32 *) rc4_key->S;

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

DECLSPEC u8 rc4_next_16 (SCR_TYPE RC4_KEY *rc4_key, u8 i, u8 j, const __global u32 *in, u32 out[4])
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

DECLSPEC void hmac_md5_pad (u32 w0[4], u32 w1[4], u32 w2[4], u32 w3[4], u32 ipad[4], u32 opad[4])
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

  ipad[0] = MD5M_A;
  ipad[1] = MD5M_B;
  ipad[2] = MD5M_C;
  ipad[3] = MD5M_D;

  md5_transform (w0, w1, w2, w3, ipad);

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

  opad[0] = MD5M_A;
  opad[1] = MD5M_B;
  opad[2] = MD5M_C;
  opad[3] = MD5M_D;

  md5_transform (w0, w1, w2, w3, opad);
}

DECLSPEC void hmac_md5_run (u32 w0[4], u32 w1[4], u32 w2[4], u32 w3[4], u32 ipad[4], u32 opad[4], u32 digest[4])
{
  digest[0] = ipad[0];
  digest[1] = ipad[1];
  digest[2] = ipad[2];
  digest[3] = ipad[3];

  md5_transform (w0, w1, w2, w3, digest);

  w0[0] = digest[0];
  w0[1] = digest[1];
  w0[2] = digest[2];
  w0[3] = digest[3];
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
  w3[2] = (64 + 16) * 8;
  w3[3] = 0;

  digest[0] = opad[0];
  digest[1] = opad[1];
  digest[2] = opad[2];
  digest[3] = opad[3];

  md5_transform (w0, w1, w2, w3, digest);
}

DECLSPEC int decrypt_and_check (SCR_TYPE RC4_KEY *rc4_key, u32 data[4], __global const u32 *edata2, const u32 edata2_len, const u32 K2[4], const u32 checksum[4])
{
  rc4_init_16 (rc4_key, data);

  u32 out0[4];
  u32 out1[4];

  u8 i = 0;
  u8 j = 0;

  /*
    8 first bytes are nonce, then ASN1 structs (DER encoding: type-length-data)

    if length >= 128 bytes:
        length is on 2 bytes and type is \x63\x82 (encode_krb5_enc_tkt_part) and data is an ASN1 sequence \x30\x82
    else:
        length is on 1 byte and type is \x63\x81 and data is an ASN1 sequence \x30\x81

    next headers follow the same ASN1 "type-length-data" scheme
  */

  j = rc4_next_16 (rc4_key, i, j, edata2 + 0, out0); i += 16;

  if (((out0[2] & 0xff00ffff) != 0x30008163) && ((out0[2] & 0x0000ffff) != 0x00008263)) return 0;

  j = rc4_next_16 (rc4_key, i, j, edata2 + 4, out1); i += 16;

  if (((out1[0] & 0x00ffffff) != 0x00000503) && (out1[0] != 0x050307A0)) return 0;

  rc4_init_16 (rc4_key, data);

  i = 0;
  j = 0;

  // init hmac

  u32 w0[4];
  u32 w1[4];
  u32 w2[4];
  u32 w3[4];

  w0[0] = K2[0];
  w0[1] = K2[1];
  w0[2] = K2[2];
  w0[3] = K2[3];
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

  u32 ipad[4];
  u32 opad[4];

  hmac_md5_pad (w0, w1, w2, w3, ipad, opad);

  int edata2_left;

  for (edata2_left = edata2_len; edata2_left >= 64; edata2_left -= 64)
  {
    j = rc4_next_16 (rc4_key, i, j, edata2, w0); i += 16; edata2 += 4;
    j = rc4_next_16 (rc4_key, i, j, edata2, w1); i += 16; edata2 += 4;
    j = rc4_next_16 (rc4_key, i, j, edata2, w2); i += 16; edata2 += 4;
    j = rc4_next_16 (rc4_key, i, j, edata2, w3); i += 16; edata2 += 4;

    md5_transform (w0, w1, w2, w3, ipad);
  }

  w0[0] = 0;
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

  if (edata2_left < 16)
  {
    j = rc4_next_16 (rc4_key, i, j, edata2, w0); i += 16; edata2 += 4;

    truncate_block_4x4_le_S (w0, edata2_left & 0xf);

    append_0x80_1x4 (w0, edata2_left & 0xf);

    w3[2] = (64 + edata2_len) * 8;
    w3[3] = 0;

    md5_transform (w0, w1, w2, w3, ipad);
  }
  else if (edata2_left < 32)
  {
    j = rc4_next_16 (rc4_key, i, j, edata2, w0); i += 16; edata2 += 4;
    j = rc4_next_16 (rc4_key, i, j, edata2, w1); i += 16; edata2 += 4;

    truncate_block_4x4_le_S (w1, edata2_left & 0xf);

    append_0x80_1x4 (w1, edata2_left & 0xf);

    w3[2] = (64 + edata2_len) * 8;
    w3[3] = 0;

    md5_transform (w0, w1, w2, w3, ipad);
  }
  else if (edata2_left < 48)
  {
    j = rc4_next_16 (rc4_key, i, j, edata2, w0); i += 16; edata2 += 4;
    j = rc4_next_16 (rc4_key, i, j, edata2, w1); i += 16; edata2 += 4;
    j = rc4_next_16 (rc4_key, i, j, edata2, w2); i += 16; edata2 += 4;

    truncate_block_4x4_le_S (w2, edata2_left & 0xf);

    append_0x80_1x4 (w2, edata2_left & 0xf);

    w3[2] = (64 + edata2_len) * 8;
    w3[3] = 0;

    md5_transform (w0, w1, w2, w3, ipad);
  }
  else
  {
    j = rc4_next_16 (rc4_key, i, j, edata2, w0); i += 16; edata2 += 4;
    j = rc4_next_16 (rc4_key, i, j, edata2, w1); i += 16; edata2 += 4;
    j = rc4_next_16 (rc4_key, i, j, edata2, w2); i += 16; edata2 += 4;
    j = rc4_next_16 (rc4_key, i, j, edata2, w3); i += 16; edata2 += 4;

    truncate_block_4x4_le_S (w3, edata2_left & 0xf);

    append_0x80_1x4 (w3, edata2_left & 0xf);

    if (edata2_left < 56)
    {
      w3[2] = (64 + edata2_len) * 8;
      w3[3] = 0;

      md5_transform (w0, w1, w2, w3, ipad);
    }
    else
    {
      md5_transform (w0, w1, w2, w3, ipad);

      w0[0] = 0;
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
      w3[2] = (64 + edata2_len) * 8;
      w3[3] = 0;

      md5_transform (w0, w1, w2, w3, ipad);
    }
  }

  w0[0] = ipad[0];
  w0[1] = ipad[1];
  w0[2] = ipad[2];
  w0[3] = ipad[3];
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
  w3[2] = (64 + 16) * 8;
  w3[3] = 0;

  md5_transform (w0, w1, w2, w3, opad);

  if (checksum[0] != opad[0]) return 0;
  if (checksum[1] != opad[1]) return 0;
  if (checksum[2] != opad[2]) return 0;
  if (checksum[3] != opad[3]) return 0;

  return 1;
}

DECLSPEC void kerb_prepare (const u32 w0[4], const u32 w1[4], const u32 pw_len, const u32 checksum[4], u32 digest[4], u32 K2[4])
{
  /**
   * pads
   */

  u32 w0_t[4];
  u32 w1_t[4];
  u32 w2_t[4];
  u32 w3_t[4];

  w0_t[0] = w0[0];
  w0_t[1] = w0[1];
  w0_t[2] = w0[2];
  w0_t[3] = w0[3];
  w1_t[0] = w1[0];
  w1_t[1] = w1[1];
  w1_t[2] = w1[2];
  w1_t[3] = w1[3];
  w2_t[0] = 0;
  w2_t[1] = 0;
  w2_t[2] = 0;
  w2_t[3] = 0;
  w3_t[0] = 0;
  w3_t[1] = 0;
  w3_t[2] = 0;
  w3_t[3] = 0;

  // K=MD4(Little_indian(UNICODE(pwd))

  append_0x80_2x4 (w0_t, w1_t, pw_len);

  make_utf16le (w1_t, w2_t, w3_t);
  make_utf16le (w0_t, w0_t, w1_t);

  w3_t[2] = pw_len * 8 * 2;
  w3_t[3] = 0;

  digest[0] = MD4M_A;
  digest[1] = MD4M_B;
  digest[2] = MD4M_C;
  digest[3] = MD4M_D;

  md4_transform (w0_t, w1_t, w2_t, w3_t, digest);

  // K1=MD5_HMAC(K,1); with 2 encoded as little indian on 4 bytes (02000000 in hexa);

  w0_t[0] = digest[0];
  w0_t[1] = digest[1];
  w0_t[2] = digest[2];
  w0_t[3] = digest[3];
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

  u32 ipad[4];
  u32 opad[4];

  hmac_md5_pad (w0_t, w1_t, w2_t, w3_t, ipad, opad);

  w0_t[0] = 2;
  w0_t[1] = 0x80;
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
  w3_t[2] = (64 + 4) * 8;
  w3_t[3] = 0;

  hmac_md5_run (w0_t, w1_t, w2_t, w3_t, ipad, opad, digest);

  // K2 = K1;

  K2[0] = digest[0];
  K2[1] = digest[1];
  K2[2] = digest[2];
  K2[3] = digest[3];

  // K3=MD5_HMAC(K1,checksum);

  w0_t[0] = digest[0];
  w0_t[1] = digest[1];
  w0_t[2] = digest[2];
  w0_t[3] = digest[3];
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

  hmac_md5_pad (w0_t, w1_t, w2_t, w3_t, ipad, opad);

  w0_t[0] = checksum[0];
  w0_t[1] = checksum[1];
  w0_t[2] = checksum[2];
  w0_t[3] = checksum[3];
  w1_t[0] = 0x80;
  w1_t[1] = 0;
  w1_t[2] = 0;
  w1_t[3] = 0;
  w2_t[0] = 0;
  w2_t[1] = 0;
  w2_t[2] = 0;
  w2_t[3] = 0;
  w3_t[0] = 0;
  w3_t[1] = 0;
  w3_t[2] = (64 + 16) * 8;
  w3_t[3] = 0;

  hmac_md5_run (w0_t, w1_t, w2_t, w3_t, ipad, opad, digest);
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m13100_m04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global krb5tgs_t *krb5tgs_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
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
   * shared
   */

  #ifdef REAL_SHM

  __local RC4_KEY rc4_keys[64];

  __local RC4_KEY *rc4_key = &rc4_keys[lid];

  #else

  RC4_KEY rc4_keys[1];

  RC4_KEY *rc4_key = &rc4_keys[0];

  #endif

  /**
   * salt
   */

  u32 checksum[4];

  checksum[0] = krb5tgs_bufs[digests_offset].checksum[0];
  checksum[1] = krb5tgs_bufs[digests_offset].checksum[1];
  checksum[2] = krb5tgs_bufs[digests_offset].checksum[2];
  checksum[3] = krb5tgs_bufs[digests_offset].checksum[3];

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

    w0[0] = wordl0[0] | wordr0[0];
    w0[1] = wordl0[1] | wordr0[1];
    w0[2] = wordl0[2] | wordr0[2];
    w0[3] = wordl0[3] | wordr0[3];
    w1[0] = wordl1[0] | wordr1[0];
    w1[1] = wordl1[1] | wordr1[1];
    w1[2] = wordl1[2] | wordr1[2];
    w1[3] = wordl1[3] | wordr1[3];

    /**
     * kerberos
     */

    u32 digest[4];

    u32 K2[4];

    kerb_prepare (w0, w1, pw_len, checksum, digest, K2);

    u32 tmp[4];

    tmp[0] = digest[0];
    tmp[1] = digest[1];
    tmp[2] = digest[2];
    tmp[3] = digest[3];

    if (decrypt_and_check (rc4_key, tmp, krb5tgs_bufs[digests_offset].edata2, krb5tgs_bufs[digests_offset].edata2_len, K2, checksum) == 1)
    {
      if (atomic_inc (&hashes_shown[digests_offset]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, salt_pos, digests_cnt, 0, digests_offset + 0, gid, il_pos);
      }
    }
  }
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m13100_m08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global krb5tgs_t *krb5tgs_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m13100_m16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global krb5tgs_t *krb5tgs_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m13100_s04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global krb5tgs_t *krb5tgs_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
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
   * shared
   */

  #ifdef REAL_SHM

  __local RC4_KEY rc4_keys[64];

  __local RC4_KEY *rc4_key = &rc4_keys[lid];

  #else

  RC4_KEY rc4_keys[1];

  RC4_KEY *rc4_key = &rc4_keys[0];

  #endif

  /**
   * salt
   */

  u32 checksum[4];

  checksum[0] = krb5tgs_bufs[digests_offset].checksum[0];
  checksum[1] = krb5tgs_bufs[digests_offset].checksum[1];
  checksum[2] = krb5tgs_bufs[digests_offset].checksum[2];
  checksum[3] = krb5tgs_bufs[digests_offset].checksum[3];

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

    w0[0] = wordl0[0] | wordr0[0];
    w0[1] = wordl0[1] | wordr0[1];
    w0[2] = wordl0[2] | wordr0[2];
    w0[3] = wordl0[3] | wordr0[3];
    w1[0] = wordl1[0] | wordr1[0];
    w1[1] = wordl1[1] | wordr1[1];
    w1[2] = wordl1[2] | wordr1[2];
    w1[3] = wordl1[3] | wordr1[3];

    /**
     * kerberos
     */

    u32 digest[4];

    u32 K2[4];

    kerb_prepare (w0, w1, pw_len, checksum, digest, K2);

    u32 tmp[4];

    tmp[0] = digest[0];
    tmp[1] = digest[1];
    tmp[2] = digest[2];
    tmp[3] = digest[3];

    if (decrypt_and_check (rc4_key, tmp, krb5tgs_bufs[digests_offset].edata2, krb5tgs_bufs[digests_offset].edata2_len, K2, checksum) == 1)
    {
      if (atomic_inc (&hashes_shown[digests_offset]) == 0)
      {
        mark_hash (plains_buf, d_return_buf, salt_pos, digests_cnt, 0, digests_offset + 0, gid, il_pos);
      }
    }
  }
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m13100_s08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global krb5tgs_t *krb5tgs_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) m13100_s16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global krb5tgs_t *krb5tgs_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
}
