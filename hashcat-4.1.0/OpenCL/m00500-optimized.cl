/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//#define NEW_SIMD_CODE

#include "inc_vendor.cl"
#include "inc_hash_constants.h"
#include "inc_hash_functions.cl"
#include "inc_types.cl"
#include "inc_common.cl"
#include "inc_hash_md5.cl"

#define COMPARE_S "inc_comp_single.cl"
#define COMPARE_M "inc_comp_multi.cl"

#define md5crypt_magic 0x00243124u

DECLSPEC void memcat16 (u32 block0[4], u32 block1[4], u32 block2[4], u32 block3[4], const u32 offset, const u32 append[4])
{
  u32 tmp0;
  u32 tmp1;
  u32 tmp2;
  u32 tmp3;
  u32 tmp4;

  const int offset_mod_4 = offset & 3;

  const int offset_minus_4 = 4 - offset_mod_4;

  #if defined IS_AMD || defined IS_GENERIC
  u32 in0 = swap32_S (append[0]);
  u32 in1 = swap32_S (append[1]);
  u32 in2 = swap32_S (append[2]);
  u32 in3 = swap32_S (append[3]);

  tmp0 = amd_bytealign (  0, in0, offset);
  tmp1 = amd_bytealign (in0, in1, offset);
  tmp2 = amd_bytealign (in1, in2, offset);
  tmp3 = amd_bytealign (in2, in3, offset);
  tmp4 = amd_bytealign (in3,   0, offset);

  tmp0 = swap32_S (tmp0);
  tmp1 = swap32_S (tmp1);
  tmp2 = swap32_S (tmp2);
  tmp3 = swap32_S (tmp3);
  tmp4 = swap32_S (tmp4);
  #endif

  #ifdef IS_NV
  const int selector = (0x76543210 >> (offset_minus_4 * 4)) & 0xffff;

  u32 in0 = append[0];
  u32 in1 = append[1];
  u32 in2 = append[2];
  u32 in3 = append[3];

  tmp0 = __byte_perm (  0, in0, selector);
  tmp1 = __byte_perm (in0, in1, selector);
  tmp2 = __byte_perm (in1, in2, selector);
  tmp3 = __byte_perm (in2, in3, selector);
  tmp4 = __byte_perm (in3,   0, selector);
  #endif

  const u32 div = offset / 4;

  switch (div)
  {
    case  0:  block0[0] |= tmp0;
              block0[1]  = tmp1;
              block0[2]  = tmp2;
              block0[3]  = tmp3;
              block1[0]  = tmp4;
              break;
    case  1:  block0[1] |= tmp0;
              block0[2]  = tmp1;
              block0[3]  = tmp2;
              block1[0]  = tmp3;
              block1[1]  = tmp4;
              break;
    case  2:  block0[2] |= tmp0;
              block0[3]  = tmp1;
              block1[0]  = tmp2;
              block1[1]  = tmp3;
              block1[2]  = tmp4;
              break;
    case  3:  block0[3] |= tmp0;
              block1[0]  = tmp1;
              block1[1]  = tmp2;
              block1[2]  = tmp3;
              block1[3]  = tmp4;
              break;
    case  4:  block1[0] |= tmp0;
              block1[1]  = tmp1;
              block1[2]  = tmp2;
              block1[3]  = tmp3;
              block2[0]  = tmp4;
              break;
    case  5:  block1[1] |= tmp0;
              block1[2]  = tmp1;
              block1[3]  = tmp2;
              block2[0]  = tmp3;
              block2[1]  = tmp4;
              break;
    case  6:  block1[2] |= tmp0;
              block1[3]  = tmp1;
              block2[0]  = tmp2;
              block2[1]  = tmp3;
              block2[2]  = tmp4;
              break;
    case  7:  block1[3] |= tmp0;
              block2[0]  = tmp1;
              block2[1]  = tmp2;
              block2[2]  = tmp3;
              block2[3]  = tmp4;
              break;
    case  8:  block2[0] |= tmp0;
              block2[1]  = tmp1;
              block2[2]  = tmp2;
              block2[3]  = tmp3;
              block3[0]  = tmp4;
              break;
    case  9:  block2[1] |= tmp0;
              block2[2]  = tmp1;
              block2[3]  = tmp2;
              block3[0]  = tmp3;
              block3[1]  = tmp4;
              break;
  }
}

DECLSPEC void memcat16_x80 (u32 block0[4], u32 block1[4], u32 block2[4], u32 block3[4], const u32 offset, const u32 append[4])
{
  u32 tmp0;
  u32 tmp1;
  u32 tmp2;
  u32 tmp3;
  u32 tmp4;

  const int offset_mod_4 = offset & 3;

  const int offset_minus_4 = 4 - offset_mod_4;

  #if defined IS_AMD || defined IS_GENERIC
  u32 in0 = swap32_S (append[0]);
  u32 in1 = swap32_S (append[1]);
  u32 in2 = swap32_S (append[2]);
  u32 in3 = swap32_S (append[3]);
  u32 in4 = 0x80000000;

  tmp0 = amd_bytealign (  0, in0, offset);
  tmp1 = amd_bytealign (in0, in1, offset);
  tmp2 = amd_bytealign (in1, in2, offset);
  tmp3 = amd_bytealign (in2, in3, offset);
  tmp4 = amd_bytealign (in3, in4, offset);

  tmp0 = swap32_S (tmp0);
  tmp1 = swap32_S (tmp1);
  tmp2 = swap32_S (tmp2);
  tmp3 = swap32_S (tmp3);
  tmp4 = swap32_S (tmp4);
  #endif

  #ifdef IS_NV
  const int selector = (0x76543210 >> (offset_minus_4 * 4)) & 0xffff;

  u32 in0 = append[0];
  u32 in1 = append[1];
  u32 in2 = append[2];
  u32 in3 = append[3];
  u32 in4 = 0x80;

  tmp0 = __byte_perm (  0, in0, selector);
  tmp1 = __byte_perm (in0, in1, selector);
  tmp2 = __byte_perm (in1, in2, selector);
  tmp3 = __byte_perm (in2, in3, selector);
  tmp4 = __byte_perm (in3, in4, selector);
  #endif

  const u32 div = offset / 4;

  switch (div)
  {
    case  0:  block0[0] |= tmp0;
              block0[1]  = tmp1;
              block0[2]  = tmp2;
              block0[3]  = tmp3;
              block1[0]  = tmp4;
              break;
    case  1:  block0[1] |= tmp0;
              block0[2]  = tmp1;
              block0[3]  = tmp2;
              block1[0]  = tmp3;
              block1[1]  = tmp4;
              break;
    case  2:  block0[2] |= tmp0;
              block0[3]  = tmp1;
              block1[0]  = tmp2;
              block1[1]  = tmp3;
              block1[2]  = tmp4;
              break;
    case  3:  block0[3] |= tmp0;
              block1[0]  = tmp1;
              block1[1]  = tmp2;
              block1[2]  = tmp3;
              block1[3]  = tmp4;
              break;
    case  4:  block1[0] |= tmp0;
              block1[1]  = tmp1;
              block1[2]  = tmp2;
              block1[3]  = tmp3;
              block2[0]  = tmp4;
              break;
    case  5:  block1[1] |= tmp0;
              block1[2]  = tmp1;
              block1[3]  = tmp2;
              block2[0]  = tmp3;
              block2[1]  = tmp4;
              break;
    case  6:  block1[2] |= tmp0;
              block1[3]  = tmp1;
              block2[0]  = tmp2;
              block2[1]  = tmp3;
              block2[2]  = tmp4;
              break;
    case  7:  block1[3] |= tmp0;
              block2[0]  = tmp1;
              block2[1]  = tmp2;
              block2[2]  = tmp3;
              block2[3]  = tmp4;
              break;
    case  8:  block2[0] |= tmp0;
              block2[1]  = tmp1;
              block2[2]  = tmp2;
              block2[3]  = tmp3;
              block3[0]  = tmp4;
              break;
    case  9:  block2[1] |= tmp0;
              block2[2]  = tmp1;
              block2[3]  = tmp2;
              block3[0]  = tmp3;
              block3[1]  = tmp4;
              break;
  }
}

DECLSPEC void memcat8 (u32 block0[4], u32 block1[4], u32 block2[4], u32 block3[4], const u32 offset, const u32 append[2])
{
  u32 tmp0;
  u32 tmp1;
  u32 tmp2;

  const int offset_mod_4 = offset & 3;

  const int offset_minus_4 = 4 - offset_mod_4;

  #if defined IS_AMD || defined IS_GENERIC
  u32 in0 = swap32_S (append[0]);
  u32 in1 = swap32_S (append[1]);

  tmp0 = amd_bytealign (  0, in0, offset);
  tmp1 = amd_bytealign (in0, in1, offset);
  tmp2 = amd_bytealign (in1,   0, offset);

  tmp0 = swap32_S (tmp0);
  tmp1 = swap32_S (tmp1);
  tmp2 = swap32_S (tmp2);
  #endif

  #ifdef IS_NV
  const int selector = (0x76543210 >> (offset_minus_4 * 4)) & 0xffff;

  u32 in0 = append[0];
  u32 in1 = append[1];

  tmp0 = __byte_perm (  0, in0, selector);
  tmp1 = __byte_perm (in0, in1, selector);
  tmp2 = __byte_perm (in1,   0, selector);
  #endif

  const u32 div = offset / 4;

  switch (div)
  {
    case  0:  block0[0] |= tmp0;
              block0[1]  = tmp1;
              block0[2]  = tmp2;
              break;
    case  1:  block0[1] |= tmp0;
              block0[2]  = tmp1;
              block0[3]  = tmp2;
              break;
    case  2:  block0[2] |= tmp0;
              block0[3]  = tmp1;
              block1[0]  = tmp2;
              break;
    case  3:  block0[3] |= tmp0;
              block1[0]  = tmp1;
              block1[1]  = tmp2;
              break;
    case  4:  block1[0] |= tmp0;
              block1[1]  = tmp1;
              block1[2]  = tmp2;
              break;
    case  5:  block1[1] |= tmp0;
              block1[2]  = tmp1;
              block1[3]  = tmp2;
              break;
    case  6:  block1[2] |= tmp0;
              block1[3]  = tmp1;
              block2[0]  = tmp2;
              break;
    case  7:  block1[3] |= tmp0;
              block2[0]  = tmp1;
              block2[1]  = tmp2;
              break;
    case  8:  block2[0] |= tmp0;
              block2[1]  = tmp1;
              block2[2]  = tmp2;
              break;
    case  9:  block2[1] |= tmp0;
              block2[2]  = tmp1;
              block2[3]  = tmp2;
              break;
    case 10:  block2[2] |= tmp0;
              block2[3]  = tmp1;
              block3[0]  = tmp2;
              break;
    case 11:  block2[3] |= tmp0;
              block3[0]  = tmp1;
              block3[1]  = tmp2;
              break;
  }
}

DECLSPEC void append_sign (u32 block0[4], u32 block1[4], const u32 block_len)
{
  switch (block_len)
  {
    case 0:
      block0[0] = md5crypt_magic;
      break;

    case 1:
      block0[0] = block0[0]            | md5crypt_magic <<  8u;
      block0[1] = md5crypt_magic >> 24u;
      break;

    case 2:
      block0[0] = block0[0]            | md5crypt_magic << 16u;
      block0[1] = md5crypt_magic >> 16u;
      break;

    case 3:
      block0[0] = block0[0]            | md5crypt_magic << 24u;
      block0[1] = md5crypt_magic >>  8u;
      break;

    case 4:
      block0[1] = md5crypt_magic;
      break;

    case 5:
      block0[1] = block0[1]            | md5crypt_magic <<  8u;
      block0[2] = md5crypt_magic >> 24u;
      break;

    case 6:
      block0[1] = block0[1]            | md5crypt_magic << 16u;
      block0[2] = md5crypt_magic >> 16u;
      break;

    case 7:
      block0[1] = block0[1]            | md5crypt_magic << 24u;
      block0[2] = md5crypt_magic >>  8u;
      break;

    case 8:
      block0[2] = md5crypt_magic;
      break;

    case 9:
      block0[2] = block0[2]            | md5crypt_magic <<  8u;
      block0[3] = md5crypt_magic >> 24u;
      break;

    case 10:
      block0[2] = block0[2]            | md5crypt_magic << 16u;
      block0[3] = md5crypt_magic >> 16u;
      break;

    case 11:
      block0[2] = block0[2]            | md5crypt_magic << 24u;
      block0[3] = md5crypt_magic >>  8u;
      break;

    case 12:
      block0[3] = md5crypt_magic;
      break;

    case 13:
      block0[3] = block0[3]            | md5crypt_magic <<  8u;
      block1[0] = md5crypt_magic >> 24u;
      break;

    case 14:
      block0[3] = block0[3]            | md5crypt_magic << 16u;
      block1[0] = md5crypt_magic >> 16u;
      break;

    case 15:
      block0[3] = block0[3]            | md5crypt_magic << 24u;
      block1[0] = md5crypt_magic >>  8u;
      break;
  }
}

DECLSPEC void append_1st (u32 block0[4], u32 block1[4], u32 block2[4], u32 block3[4], const u32 block_len, const u32 append)
{
  switch (block_len)
  {
    case 0:
      block0[0] = append;
      break;

    case 1:
      block0[0] = block0[0] | append <<  8;
      break;

    case 2:
      block0[0] = block0[0] | append << 16;
      break;

    case 3:
      block0[0] = block0[0] | append << 24;
      break;

    case 4:
      block0[1] = append;
      break;

    case 5:
      block0[1] = block0[1] | append <<  8;
      break;

    case 6:
      block0[1] = block0[1] | append << 16;
      break;

    case 7:
      block0[1] = block0[1] | append << 24;
      break;

    case 8:
      block0[2] = append;
      break;

    case 9:
      block0[2] = block0[2] | append <<  8;
      break;

    case 10:
      block0[2] = block0[2] | append << 16;
      break;

    case 11:
      block0[2] = block0[2] | append << 24;
      break;

    case 12:
      block0[3] = append;
      break;

    case 13:
      block0[3] = block0[3] | append <<  8;
      break;

    case 14:
      block0[3] = block0[3] | append << 16;
      break;

    case 15:
      block0[3] = block0[3] | append << 24;
      break;

    case 16:
      block1[0] = append;
      break;

    case 17:
      block1[0] = block1[0] | append <<  8;
      break;

    case 18:
      block1[0] = block1[0] | append << 16;
      break;

    case 19:
      block1[0] = block1[0] | append << 24;
      break;

    case 20:
      block1[1] = append;
      break;

    case 21:
      block1[1] = block1[1] | append <<  8;
      break;

    case 22:
      block1[1] = block1[1] | append << 16;
      break;

    case 23:
      block1[1] = block1[1] | append << 24;
      break;

    case 24:
      block1[2] = append;
      break;

    case 25:
      block1[2] = block1[2] | append <<  8;
      break;

    case 26:
      block1[2] = block1[2] | append << 16;
      break;

    case 27:
      block1[2] = block1[2] | append << 24;
      break;

    case 28:
      block1[3] = append;
      break;

    case 29:
      block1[3] = block1[3] | append <<  8;
      break;

    case 30:
      block1[3] = block1[3] | append << 16;
      break;

    case 31:
      block1[3] = block1[3] | append << 24;
      break;

    case 32:
      block2[0] = append;
      break;

    case 33:
      block2[0] = block2[0] | append <<  8;
      break;

    case 34:
      block2[0] = block2[0] | append << 16;
      break;

    case 35:
      block2[0] = block2[0] | append << 24;
      break;

    case 36:
      block2[1] = append;
      break;

    case 37:
      block2[1] = block2[1] | append <<  8;
      break;

    case 38:
      block2[1] = block2[1] | append << 16;
      break;

    case 39:
      block2[1] = block2[1] | append << 24;
      break;

    case 40:
      block2[2] = append;
      break;

    case 41:
      block2[2] = block2[2] | append <<  8;
      break;

    case 42:
      block2[2] = block2[2] | append << 16;
      break;

    case 43:
      block2[2] = block2[2] | append << 24;
      break;

    case 44:
      block2[3] = append;
      break;

    case 45:
      block2[3] = block2[3] | append <<  8;
      break;

    case 46:
      block2[3] = block2[3] | append << 16;
      break;

    case 47:
      block2[3] = block2[3] | append << 24;
      break;

    case 48:
      block3[0] = append;
      break;

    case 49:
      block3[0] = block3[0] | append <<  8;
      break;

    case 50:
      block3[0] = block3[0] | append << 16;
      break;

    case 51:
      block3[0] = block3[0] | append << 24;
      break;

    case 52:
      block3[1] = append;
      break;

    case 53:
      block3[1] = block3[1] | append <<  8;
      break;

    case 54:
      block3[1] = block3[1] | append << 16;
      break;

    case 55:
      block3[1] = block3[1] | append << 24;
      break;

    case 56:
      block3[2] = append;
      break;
  }
}

__kernel void m00500_init (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global md5crypt_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 w0[4];

  w0[0] = pws[gid].i[0];
  w0[1] = pws[gid].i[1];
  w0[2] = pws[gid].i[2];
  w0[3] = pws[gid].i[3];

  const u32 pw_len = pws[gid].pw_len;

  /**
   * salt
   */

  u32 salt_buf[2];

  salt_buf[0] = salt_bufs[salt_pos].salt_buf[0];
  salt_buf[1] = salt_bufs[salt_pos].salt_buf[1];

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  /**
   * init
   */

  //memcat16 (block0, block1, block2, block3, block_len, w0);
  //block_len += pw_len;

  u32 block_len = pw_len;

  u32 block0[4];

  block0[0] = w0[0];
  block0[1] = w0[1];
  block0[2] = w0[2];
  block0[3] = w0[3];

  u32 block1[4];

  block1[0] = 0;
  block1[1] = 0;
  block1[2] = 0;
  block1[3] = 0;

  u32 block2[4];

  block2[0] = 0;
  block2[1] = 0;
  block2[2] = 0;
  block2[3] = 0;

  u32 block3[4];

  block3[0] = 0;
  block3[1] = 0;
  block3[2] = 0;
  block3[3] = 0;

  memcat8 (block0, block1, block2, block3, block_len, salt_buf);

  block_len += salt_len;

  memcat16 (block0, block1, block2, block3, block_len, w0);

  block_len += pw_len;

  append_0x80_4x4 (block0, block1, block2, block3, block_len);

  block3[2] = block_len * 8;

  u32 digest[4];

  digest[0] = MD5M_A;
  digest[1] = MD5M_B;
  digest[2] = MD5M_C;
  digest[3] = MD5M_D;

  md5_transform (block0, block1, block2, block3, digest);

  /* The password first, since that is what is most unknown */
  /* Then our magic string */
  /* Then the raw salt */
  /* Then just as many characters of the MD5(pw,salt,pw) */

  //memcat16 (block0, block1, block2, block3, block_len, w);
  //block_len += pw_len;

  block_len = pw_len;

  block0[0] = w0[0];
  block0[1] = w0[1];
  block0[2] = w0[2];
  block0[3] = w0[3];

  block1[0] = 0;
  block1[1] = 0;
  block1[2] = 0;
  block1[3] = 0;

  block2[0] = 0;
  block2[1] = 0;
  block2[2] = 0;
  block2[3] = 0;

  block3[0] = 0;
  block3[1] = 0;
  block3[2] = 0;
  block3[3] = 0;

  append_sign (block0, block1, block_len);

  block_len += 3;

  memcat8 (block0, block1, block2, block3, block_len, salt_buf);

  block_len += salt_len;

  truncate_block_4x4_le_S (digest, pw_len);

  memcat16 (block0, block1, block2, block3, block_len, digest);

  block_len += pw_len;

  /* Then something really weird... */

  u32 append = block0[0] & 0xFF;

  for (u32 j = pw_len; j; j >>= 1)
  {
    if ((j & 1) == 0)
    {
      append_1st (block0, block1, block2, block3, block_len, append);
    }

    block_len++;
  }

  append_0x80_4x4 (block0, block1, block2, block3, block_len);

  block3[2] = block_len * 8;

  digest[0] = MD5M_A;
  digest[1] = MD5M_B;
  digest[2] = MD5M_C;
  digest[3] = MD5M_D;

  md5_transform (block0, block1, block2, block3, digest);

  tmps[gid].digest_buf[0] = digest[0];
  tmps[gid].digest_buf[1] = digest[1];
  tmps[gid].digest_buf[2] = digest[2];
  tmps[gid].digest_buf[3] = digest[3];
}

__kernel void m00500_loop (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global md5crypt_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * base
   */

  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32 w0[4];

  w0[0] = pws[gid].i[0];
  w0[1] = pws[gid].i[1];
  w0[2] = pws[gid].i[2];
  w0[3] = pws[gid].i[3];

  const u32 pw_len = pws[gid].pw_len;

  u32 w0_x80[4];

  w0_x80[0] = w0[0];
  w0_x80[1] = w0[1];
  w0_x80[2] = w0[2];
  w0_x80[3] = w0[3];

  append_0x80_1x4 (w0_x80, pw_len);

  /**
   * salt
   */

  u32 salt_buf[2];

  salt_buf[0] = salt_bufs[salt_pos].salt_buf[0];
  salt_buf[1] = salt_bufs[salt_pos].salt_buf[1];

  const u32 salt_len = salt_bufs[salt_pos].salt_len;

  /**
   * digest
   */

  u32 digest[4];

  digest[0] = tmps[gid].digest_buf[0];
  digest[1] = tmps[gid].digest_buf[1];
  digest[2] = tmps[gid].digest_buf[2];
  digest[3] = tmps[gid].digest_buf[3];

  /**
   * loop
   */

  /* and now, just to make sure things don't run too fast */

  u32 block_len;

  u32 block0[4];

  block0[0] = 0;
  block0[1] = 0;
  block0[2] = 0;
  block0[3] = 0;

  u32 block1[4];

  block1[0] = 0;
  block1[1] = 0;
  block1[2] = 0;
  block1[3] = 0;

  u32 block2[4];

  block2[0] = 0;
  block2[1] = 0;
  block2[2] = 0;
  block2[3] = 0;

  u32 block3[4];

  block3[0] = 0;
  block3[1] = 0;
  block3[2] = 0;
  block3[3] = 0;

  for (u32 i = 0, j = loop_pos; i < loop_cnt; i++, j++)
  {
    block1[0] = 0;
    block1[1] = 0;
    block1[2] = 0;
    block1[3] = 0;
    block2[0] = 0;
    block2[1] = 0;
    block2[2] = 0;
    block2[3] = 0;
    block3[0] = 0;
    block3[1] = 0;

    const u32 j1 = (j & 1) ? 1 : 0;
    const u32 j3 = (j % 3) ? 1 : 0;
    const u32 j7 = (j % 7) ? 1 : 0;

    if (j1)
    {
      block0[0] = w0[0];
      block0[1] = w0[1];
      block0[2] = w0[2];
      block0[3] = w0[3];

      block_len = pw_len;

      if (j3)
      {
        memcat8 (block0, block1, block2, block3, block_len, salt_buf);

        block_len += salt_len;
      }

      if (j7)
      {
        memcat16 (block0, block1, block2, block3, block_len, w0);

        block_len += pw_len;
      }

      memcat16_x80 (block0, block1, block2, block3, block_len, digest);

      block_len += 16;
    }
    else
    {
      block0[0] = digest[0];
      block0[1] = digest[1];
      block0[2] = digest[2];
      block0[3] = digest[3];

      block_len = 16;

      if (j3 && j7)
      {
        block1[0] = salt_buf[0];
        block1[1] = salt_buf[1];

        block_len += salt_len;

        memcat16 (block0, block1, block2, block3, block_len, w0);

        block_len += pw_len;
      }
      else if (j3)
      {
        block1[0] = salt_buf[0];
        block1[1] = salt_buf[1];

        block_len += salt_len;
      }
      else if (j7)
      {
        block1[0] = w0[0];
        block1[1] = w0[1];
        block1[2] = w0[2];
        block1[3] = w0[3];

        block_len += pw_len;
      }

      memcat16 (block0, block1, block2, block3, block_len, w0_x80);

      block_len += pw_len;
    }

    block3[2] = block_len * 8;

    digest[0] = MD5M_A;
    digest[1] = MD5M_B;
    digest[2] = MD5M_C;
    digest[3] = MD5M_D;

    md5_transform (block0, block1, block2, block3, digest);
  }

  tmps[gid].digest_buf[0] = digest[0];
  tmps[gid].digest_buf[1] = digest[1];
  tmps[gid].digest_buf[2] = digest[2];
  tmps[gid].digest_buf[3] = digest[3];
}

__kernel void m00500_comp (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global md5crypt_tmp_t *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
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

  const u32 r0 = tmps[gid].digest_buf[DGST_R0];
  const u32 r1 = tmps[gid].digest_buf[DGST_R1];
  const u32 r2 = tmps[gid].digest_buf[DGST_R2];
  const u32 r3 = tmps[gid].digest_buf[DGST_R3];

  #define il_pos 0

  #include COMPARE_M
}
