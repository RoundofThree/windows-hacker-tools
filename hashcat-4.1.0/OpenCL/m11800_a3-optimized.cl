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

#define INITVAL 0

#if   VECT_SIZE == 1
#define BOX(S,n,i) (S)[(n)][(i)]
#elif VECT_SIZE == 2
#define BOX(S,n,i) (u64x) ((S)[(n)][(i).s0], (S)[(n)][(i).s1])
#elif VECT_SIZE == 4
#define BOX(S,n,i) (u64x) ((S)[(n)][(i).s0], (S)[(n)][(i).s1], (S)[(n)][(i).s2], (S)[(n)][(i).s3])
#elif VECT_SIZE == 8
#define BOX(S,n,i) (u64x) ((S)[(n)][(i).s0], (S)[(n)][(i).s1], (S)[(n)][(i).s2], (S)[(n)][(i).s3], (S)[(n)][(i).s4], (S)[(n)][(i).s5], (S)[(n)][(i).s6], (S)[(n)][(i).s7])
#elif VECT_SIZE == 16
#define BOX(S,n,i) (u64x) ((S)[(n)][(i).s0], (S)[(n)][(i).s1], (S)[(n)][(i).s2], (S)[(n)][(i).s3], (S)[(n)][(i).s4], (S)[(n)][(i).s5], (S)[(n)][(i).s6], (S)[(n)][(i).s7], (S)[(n)][(i).s8], (S)[(n)][(i).s9], (S)[(n)][(i).sa], (S)[(n)][(i).sb], (S)[(n)][(i).sc], (S)[(n)][(i).sd], (S)[(n)][(i).se], (S)[(n)][(i).sf])
#endif

#define SBOG_LPSti64                                  \
  BOX (s_sbob_sl64, 0, ((t[0] >> (i * 8)) & 0xff)) ^  \
  BOX (s_sbob_sl64, 1, ((t[1] >> (i * 8)) & 0xff)) ^  \
  BOX (s_sbob_sl64, 2, ((t[2] >> (i * 8)) & 0xff)) ^  \
  BOX (s_sbob_sl64, 3, ((t[3] >> (i * 8)) & 0xff)) ^  \
  BOX (s_sbob_sl64, 4, ((t[4] >> (i * 8)) & 0xff)) ^  \
  BOX (s_sbob_sl64, 5, ((t[5] >> (i * 8)) & 0xff)) ^  \
  BOX (s_sbob_sl64, 6, ((t[6] >> (i * 8)) & 0xff)) ^  \
  BOX (s_sbob_sl64, 7, ((t[7] >> (i * 8)) & 0xff))

// constants

__constant u64a sbob_sl64[8][256] =
{
  {
    0xd031c397ce553fe6,
    0x16ba5b01b006b525,
    0xa89bade6296e70c8,
    0x6a1f525d77d3435b,
    0x6e103570573dfa0b,
    0x660efb2a17fc95ab,
    0x76327a9e97634bf6,
    0x4bad9d6462458bf5,
    0xf1830caedbc3f748,
    0xc5c8f542669131ff,
    0x95044a1cdc48b0cb,
    0x892962df3cf8b866,
    0xb0b9e208e930c135,
    0xa14fb3f0611a767c,
    0x8d2605f21c160136,
    0xd6b71922fecc549e,
    0x37089438a5907d8b,
    0x0b5da38e5803d49c,
    0x5a5bcc9cea6f3cbc,
    0xedae246d3b73ffe5,
    0xd2b87e0fde22edce,
    0x5e54abb1ca8185ec,
    0x1de7f88fe80561b9,
    0xad5e1a870135a08c,
    0x2f2adbd665cecc76,
    0x5780b5a782f58358,
    0x3edc8a2eede47b3f,
    0xc9d95c3506bee70f,
    0x83be111d6c4e05ee,
    0xa603b90959367410,
    0x103c81b4809fde5d,
    0x2c69b6027d0c774a,
    0x399080d7d5c87953,
    0x09d41e16487406b4,
    0xcdd63b1826505e5f,
    0xf99dc2f49b0298e8,
    0x9cd0540a943cb67f,
    0xbca84b7f891f17c5,
    0x723d1db3b78df2a6,
    0x78aa6e71e73b4f2e,
    0x1433e699a071670d,
    0x84f21be454620782,
    0x98df3327b4d20f2f,
    0xf049dce2d3769e5c,
    0xdb6c60199656eb7a,
    0x648746b2078b4783,
    0x32cd23598dcbadcf,
    0x1ea4955bf0c7da85,
    0xe9a143401b9d46b5,
    0xfd92a5d9bbec21b8,
    0xc8138c790e0b8e1b,
    0x2ee00b9a6d7ba562,
    0xf85712b893b7f1fc,
    0xeb28fed80bea949d,
    0x564a65eb8a40ea4c,
    0x6c9988e8474a2823,
    0x4535898b121d8f2d,
    0xabd8c03231accbf4,
    0xba2e91cab9867cbd,
    0x7960be3def8e263a,
    0x0c11a977602fd6f0,
    0xcb50e1ad16c93527,
    0xeae22e94035ffd89,
    0x2866d12f5de2ce1a,
    0xff1b1841ab9bf390,
    0x9f9339de8cfe0d43,
    0x964727c8c48a0bf7,
    0x524502c6aaae531c,
    0x9b9c5ef3ac10b413,
    0x4fa2fa4942ab32a5,
    0x3f165a62e551122b,
    0xc74148da76e6e3d7,
    0x924840e5e464b2a7,
    0xd372ae43d69784da,
    0x233b72a105e11a86,
    0xa48a04914941a638,
    0xb4b68525c9de7865,
    0xddeabaaca6cf8002,
    0x0a9773c250b6bd88,
    0xc284ffbb5ebd3393,
    0x8ba0df472c8f6a4e,
    0x2aef6cb74d951c32,
    0x427983722a318d41,
    0x73f7cdffbf389bb2,
    0x074c0af9382c026c,
    0x8a6a0f0b243a035a,
    0x6fdae53c5f88931f,
    0xc68b98967e538ac3,
    0x44ff59c71aa8e639,
    0xe2fce0ce439e9229,
    0xa20cde2479d8cd40,
    0x19e89fa2c8ebd8e9,
    0xf446bbcff398270c,
    0x43b3533e2284e455,
    0xd82f0dcd8e945046,
    0x51066f12b26ce820,
    0xe73957af6bc5426d,
    0x081ece5a40c16fa0,
    0x3b193d4fc5bfab7b,
    0x7fe66488df174d42,
    0x0e9814ef705804d8,
    0x8137ac857c39d7c6,
    0xb1733244e185a821,
    0x695c3f896f11f867,
    0xf6cf0657e3eff524,
    0x1aabf276d02963d5,
    0x2da3664e75b91e5e,
    0x0289bd981077d228,
    0x90c1fd7df413608f,
    0x3c5537b6fd93a917,
    0xaa12107e3919a2e0,
    0x0686dab530996b78,
    0xdaa6b0559ee3826e,
    0xc34e2ff756085a87,
    0x6d5358a44fff4137,
    0xfc587595b35948ac,
    0x7ca5095cc7d5f67e,
    0xfb147f6c8b754ac0,
    0xbfeb26ab91ddacf9,
    0x6896efc567a49173,
    0xca9a31e11e7c5c33,
    0xbbe44186b13315a9,
    0x0ddb793b689abfe4,
    0x70b4a02ba7fa208e,
    0xe47a3a7b7307f951,
    0x8cecd5be14a36822,
    0xeeed49b923b144d9,
    0x17708b4db8b3dc31,
    0x6088219f2765fed3,
    0xb3fa8fdcf1f27a09,
    0x910b2d31fca6099b,
    0x0f52c4a378ed6dcc,
    0x50ccbf5ebad98134,
    0x6bd582117f662a4f,
    0x94ce9a50d4fdd9df,
    0x2b25bcfb45207526,
    0x67c42b661f49fcbf,
    0x492420fc723259dd,
    0x03436dd418c2bb3c,
    0x1f6e4517f872b391,
    0xa08563bc69af1f68,
    0xd43ea4baeebb86b6,
    0x01cad04c08b56914,
    0xac94cacb0980c998,
    0x54c3d8739a373864,
    0x26fec5c02dbacac2,
    0xdea9d778be0d3b3e,
    0x040f672d20eeb950,
    0xe5b0ea377bb29045,
    0xf30ab136cbb42560,
    0x62019c0737122cfb,
    0xe86b930c13282fa1,
    0xcc1ceb542ee5374b,
    0x538fd28aa21b3a08,
    0x1b61223ad89c0ac1,
    0x36c24474ad25149f,
    0x7a23d3e9f74c9d06,
    0xbe21f6e79968c5ed,
    0xcf5f868036278c77,
    0xf705d61beb5a9c30,
    0x4d2b47d152dce08d,
    0x5f9e7bfdc234ecf8,
    0x247778583dcd18ea,
    0x867ba67c4415d5aa,
    0x4ce1979d5a698999,
    0x0000000000000000,
    0xec64f42133c696f1,
    0xb57c5569c16b1171,
    0xc1c7926f467f88af,
    0x654d96fe0f3e2e97,
    0x15f936d5a8c40e19,
    0xb8a72c52a9f1ae95,
    0xa9517daa21db19dc,
    0x58d27104fa18ee94,
    0x5918a148f2ad8780,
    0x5cdd1629daf657c4,
    0x8274c15164fb6cfa,
    0xd1fb13dbc6e056f2,
    0x7d6fd910cf609f6a,
    0xb63f38bdd9a9aa4d,
    0x3d9fe7faf526c003,
    0x74bbc706871499de,
    0xdf630734b6b8522a,
    0x3ad3ed03cd0ac26f,
    0xfadeaf2083c023d4,
    0xc00d42234ecae1bb,
    0x8538cba85cd76e96,
    0xc402250e6e2458eb,
    0x47bc3413026a5d05,
    0xafd7a71f114272a4,
    0x978df784cc3f62e3,
    0xb96dfc1ea144c781,
    0x21b2cf391596c8ae,
    0x318e4e8d950916f3,
    0xce9556cc3e92e563,
    0x385a509bdd7d1047,
    0x358129a0b5e7afa3,
    0xe6f387e363702b79,
    0xe0755d5653e94001,
    0x7be903a5fff9f412,
    0x12b53c2c90e80c75,
    0x3307f315857ec4db,
    0x8fafb86a0c61d31e,
    0xd9e5dd8186213952,
    0x77f8aad29fd622e2,
    0x25bda814357871fe,
    0x7571174a8fa1f0ca,
    0x137fec60985d6561,
    0x30449ec19dbc7fe7,
    0xa540d4dd41f4cf2c,
    0xdc206ae0ae7ae916,
    0x5b911cd0e2da55a8,
    0xb2305f90f947131d,
    0x344bf9ecbd52c6b7,
    0x5d17c665d2433ed0,
    0x18224feec05eb1fd,
    0x9e59e992844b6457,
    0x9a568ebfa4a5dd07,
    0xa3c60e68716da454,
    0x7e2cb4c4d7a22456,
    0x87b176304ca0bcbe,
    0x413aeea632f3367d,
    0x9915e36bbc67663b,
    0x40f03eea3a465f69,
    0x1c2d28c3e0b008ad,
    0x4e682a054a1e5bb1,
    0x05c5b761285bd044,
    0xe1bf8d1a5b5c2915,
    0xf2c0617ac3014c74,
    0xb7f5e8f1d11cc359,
    0x63cb4c4b3fa745ef,
    0x9d1a84469c89df6b,
    0xe33630824b2bfb3d,
    0xd5f474f6e60eefa2,
    0xf58c6b83fb2d4e18,
    0x4676e45f0adf3411,
    0x20781f751d23a1ba,
    0xbd629b3381aa7ed1,
    0xae1d775319f71bb0,
    0xfed1c80da32e9a84,
    0x5509083f92825170,
    0x29ac01635557a70e,
    0xa7c9694551831d04,
    0x8e65682604d4ba0a,
    0x11f651f8882ab749,
    0xd77dc96ef6793d8a,
    0xef2799f52b042dcd,
    0x48eef0b07a8730c9,
    0x22f1a2ed0d547392,
    0x6142f1d32fd097c7,
    0x4a674d286af0e2e1,
    0x80fd7cc9748cbed2,
    0x717e7067af4f499a,
    0x938290a9ecd1dbb3,
    0x88e3b293344dd172,
    0x2734158c250fa3d6,
  },
  {
    0x7e37e62dfc7d40c3,
    0x776f25a4ee939e5b,
    0xe045c850dd8fb5ad,
    0x86ed5ba711ff1952,
    0xe91d0bd9cf616b35,
    0x37e0ab256e408ffb,
    0x9607f6c031025a7a,
    0x0b02f5e116d23c9d,
    0xf3d8486bfb50650c,
    0x621cff27c40875f5,
    0x7d40cb71fa5fd34a,
    0x6daa6616daa29062,
    0x9f5f354923ec84e2,
    0xec847c3dc507c3b3,
    0x025a3668043ce205,
    0xa8bf9e6c4dac0b19,
    0xfa808be2e9bebb94,
    0xb5b99c5277c74fa3,
    0x78d9bc95f0397bcc,
    0xe332e50cdbad2624,
    0xc74fce129332797e,
    0x1729eceb2ea709ab,
    0xc2d6b9f69954d1f8,
    0x5d898cbfbab8551a,
    0x859a76fb17dd8adb,
    0x1be85886362f7fb5,
    0xf6413f8ff136cd8a,
    0xd3110fa5bbb7e35c,
    0x0a2feed514cc4d11,
    0xe83010edcd7f1ab9,
    0xa1e75de55f42d581,
    0xeede4a55c13b21b6,
    0xf2f5535ff94e1480,
    0x0cc1b46d1888761e,
    0xbce15fdb6529913b,
    0x2d25e8975a7181c2,
    0x71817f1ce2d7a554,
    0x2e52c5cb5c53124b,
    0xf9f7a6beef9c281d,
    0x9e722e7d21f2f56e,
    0xce170d9b81dca7e6,
    0x0e9b82051cb4941b,
    0x1e712f623c49d733,
    0x21e45cfa42f9f7dc,
    0xcb8e7a7f8bba0f60,
    0x8e98831a010fb646,
    0x474ccf0d8e895b23,
    0xa99285584fb27a95,
    0x8cc2b57205335443,
    0x42d5b8e984eff3a5,
    0x012d1b34021e718c,
    0x57a6626aae74180b,
    0xff19fc06e3d81312,
    0x35ba9d4d6a7c6dfe,
    0xc9d44c178f86ed65,
    0x506523e6a02e5288,
    0x03772d5c06229389,
    0x8b01f4fe0b691ec0,
    0xf8dabd8aed825991,
    0x4c4e3aec985b67be,
    0xb10df0827fbf96a9,
    0x6a69279ad4f8dae1,
    0xe78689dcd3d5ff2e,
    0x812e1a2b1fa553d1,
    0xfbad90d6eba0ca18,
    0x1ac543b234310e39,
    0x1604f7df2cb97827,
    0xa6241c6951189f02,
    0x753513cceaaf7c5e,
    0x64f2a59fc84c4efa,
    0x247d2b1e489f5f5a,
    0xdb64d718ab474c48,
    0x79f4a7a1f2270a40,
    0x1573da832a9bebae,
    0x3497867968621c72,
    0x514838d2a2302304,
    0xf0af6537fd72f685,
    0x1d06023e3a6b44ba,
    0x678588c3ce6edd73,
    0x66a893f7cc70acff,
    0xd4d24e29b5eda9df,
    0x3856321470ea6a6c,
    0x07c3418c0e5a4a83,
    0x2bcbb22f5635bacd,
    0x04b46cd00878d90a,
    0x06ee5ab80c443b0f,
    0x3b211f4876c8f9e5,
    0x0958c38912eede98,
    0xd14b39cdbf8b0159,
    0x397b292072f41be0,
    0x87c0409313e168de,
    0xad26e98847caa39f,
    0x4e140c849c6785bb,
    0xd5ff551db7f3d853,
    0xa0ca46d15d5ca40d,
    0xcd6020c787fe346f,
    0x84b76dcf15c3fb57,
    0xdefda0fca121e4ce,
    0x4b8d7b6096012d3d,
    0x9ac642ad298a2c64,
    0x0875d8bd10f0af14,
    0xb357c6ea7b8374ac,
    0x4d6321d89a451632,
    0xeda96709c719b23f,
    0xf76c24bbf328bc06,
    0xc662d526912c08f2,
    0x3ce25ec47892b366,
    0xb978283f6f4f39bd,
    0xc08c8f9e9d6833fd,
    0x4f3917b09e79f437,
    0x593de06fb2c08c10,
    0xd6887841b1d14bda,
    0x19b26eee32139db0,
    0xb494876675d93e2f,
    0x825937771987c058,
    0x90e9ac783d466175,
    0xf1827e03ff6c8709,
    0x945dc0a8353eb87f,
    0x4516f9658ab5b926,
    0x3f9573987eb020ef,
    0xb855330b6d514831,
    0x2ae6a91b542bcb41,
    0x6331e413c6160479,
    0x408f8e8180d311a0,
    0xeff35161c325503a,
    0xd06622f9bd9570d5,
    0x8876d9a20d4b8d49,
    0xa5533135573a0c8b,
    0xe168d364df91c421,
    0xf41b09e7f50a2f8f,
    0x12b09b0f24c1a12d,
    0xda49cc2ca9593dc4,
    0x1f5c34563e57a6bf,
    0x54d14f36a8568b82,
    0xaf7cdfe043f6419a,
    0xea6a2685c943f8bc,
    0xe5dcbfb4d7e91d2b,
    0xb27addde799d0520,
    0x6b443caed6e6ab6d,
    0x7bae91c9f61be845,
    0x3eb868ac7cae5163,
    0x11c7b65322e332a4,
    0xd23c1491b9a992d0,
    0x8fb5982e0311c7ca,
    0x70ac6428e0c9d4d8,
    0x895bc2960f55fcc5,
    0x76423e90ec8defd7,
    0x6ff0507ede9e7267,
    0x3dcf45f07a8cc2ea,
    0x4aa06054941f5cb1,
    0x5810fb5bb0defd9c,
    0x5efea1e3bc9ac693,
    0x6edd4b4adc8003eb,
    0x741808f8e8b10dd2,
    0x145ec1b728859a22,
    0x28bc9f7350172944,
    0x270a06424ebdccd3,
    0x972aedf4331c2bf6,
    0x059977e40a66a886,
    0x2550302a4a812ed6,
    0xdd8a8da0a7037747,
    0xc515f87a970e9b7b,
    0x3023eaa9601ac578,
    0xb7e3aa3a73fbada6,
    0x0fb699311eaae597,
    0x0000000000000000,
    0x310ef19d6204b4f4,
    0x229371a644db6455,
    0x0decaf591a960792,
    0x5ca4978bb8a62496,
    0x1c2b190a38753536,
    0x41a295b582cd602c,
    0x3279dcc16426277d,
    0xc1a194aa9f764271,
    0x139d803b26dfd0a1,
    0xae51c4d441e83016,
    0xd813fa44ad65dfc1,
    0xac0bf2bc45d4d213,
    0x23be6a9246c515d9,
    0x49d74d08923dcf38,
    0x9d05032127d066e7,
    0x2f7fdeff5e4d63c7,
    0xa47e2a0155247d07,
    0x99b16ff12fa8bfed,
    0x4661d4398c972aaf,
    0xdfd0bbc8a33f9542,
    0xdca79694a51d06cb,
    0xb020ebb67da1e725,
    0xba0f0563696daa34,
    0xe4f1a480d5f76ca7,
    0xc438e34e9510eaf7,
    0x939e81243b64f2fc,
    0x8defae46072d25cf,
    0x2c08f3a3586ff04e,
    0xd7a56375b3cf3a56,
    0x20c947ce40e78650,
    0x43f8a3dd86f18229,
    0x568b795eac6a6987,
    0x8003011f1dbb225d,
    0xf53612d3f7145e03,
    0x189f75da300dec3c,
    0x9570db9c3720c9f3,
    0xbb221e576b73dbb8,
    0x72f65240e4f536dd,
    0x443be25188abc8aa,
    0xe21ffe38d9b357a8,
    0xfd43ca6ee7e4f117,
    0xcaa3614b89a47eec,
    0xfe34e732e1c6629e,
    0x83742c431b99b1d4,
    0xcf3a16af83c2d66a,
    0xaae5a8044990e91c,
    0x26271d764ca3bd5f,
    0x91c4b74c3f5810f9,
    0x7c6dd045f841a2c6,
    0x7f1afd19fe63314f,
    0xc8f957238d989ce9,
    0xa709075d5306ee8e,
    0x55fc5402aa48fa0e,
    0x48fa563c9023beb4,
    0x65dfbeabca523f76,
    0x6c877d22d8bce1ee,
    0xcc4d3bf385e045e3,
    0xbebb69b36115733e,
    0x10eaad6720fd4328,
    0xb6ceb10e71e5dc2a,
    0xbdcc44ef6737e0b7,
    0x523f158ea412b08d,
    0x989c74c52db6ce61,
    0x9beb59992b945de8,
    0x8a2cefca09776f4c,
    0xa3bd6b8d5b7e3784,
    0xeb473db1cb5d8930,
    0xc3fba2c29b4aa074,
    0x9c28181525ce176b,
    0x683311f2d0c438e4,
    0x5fd3bad7be84b71f,
    0xfc6ed15ae5fa809b,
    0x36cdb0116c5efe77,
    0x29918447520958c8,
    0xa29070b959604608,
    0x53120ebaa60cc101,
    0x3a0c047c74d68869,
    0x691e0ac6d2da4968,
    0x73db4974e6eb4751,
    0x7a838afdf40599c9,
    0x5a4acd33b4e21f99,
    0x6046c94fc03497f0,
    0xe6ab92e8d1cb8ea2,
    0x3354c7f5663856f1,
    0xd93ee170af7bae4d,
    0x616bd27bc22ae67c,
    0x92b39a10397a8370,
    0xabc8b3304b8e9890,
    0xbf967287630b02b2,
    0x5b67d607b6fc6e15,
  },
  {
    0x8ab0a96846e06a6d,
    0x43c7e80b4bf0b33a,
    0x08c9b3546b161ee5,
    0x39f1c235eba990be,
    0xc1bef2376606c7b2,
    0x2c209233614569aa,
    0xeb01523b6fc3289a,
    0x946953ab935acedd,
    0x272838f63e13340e,
    0x8b0455eca12ba052,
    0x77a1b2c4978ff8a2,
    0xa55122ca13e54086,
    0x2276135862d3f1cd,
    0xdb8ddfde08b76cfe,
    0x5d1e12c89e4a178a,
    0x0e56816b03969867,
    0xee5f79953303ed59,
    0xafed748bab78d71d,
    0x6d929f2df93e53ee,
    0xf5d8a8f8ba798c2a,
    0xf619b1698e39cf6b,
    0x95ddaf2f749104e2,
    0xec2a9c80e0886427,
    0xce5c8fd8825b95ea,
    0xc4e0d9993ac60271,
    0x4699c3a5173076f9,
    0x3d1b151f50a29f42,
    0x9ed505ea2bc75946,
    0x34665acfdc7f4b98,
    0x61b1fb53292342f7,
    0xc721c0080e864130,
    0x8693cd1696fd7b74,
    0x872731927136b14b,
    0xd3446c8a63a1721b,
    0x669a35e8a6680e4a,
    0xcab658f239509a16,
    0xa4e5de4ef42e8ab9,
    0x37a7435ee83f08d9,
    0x134e6239e26c7f96,
    0x82791a3c2df67488,
    0x3f6ef00a8329163c,
    0x8e5a7e42fdeb6591,
    0x5caaee4c7981ddb5,
    0x19f234785af1e80d,
    0x255ddde3ed98bd70,
    0x50898a32a99cccac,
    0x28ca4519da4e6656,
    0xae59880f4cb31d22,
    0x0d9798fa37d6db26,
    0x32f968f0b4ffcd1a,
    0xa00f09644f258545,
    0xfa3ad5175e24de72,
    0xf46c547c5db24615,
    0x713e80fbff0f7e20,
    0x7843cf2b73d2aafa,
    0xbd17ea36aedf62b4,
    0xfd111bacd16f92cf,
    0x4abaa7dbc72d67e0,
    0xb3416b5dad49fad3,
    0xbca316b24914a88b,
    0x15d150068aecf914,
    0xe27c1debe31efc40,
    0x4fe48c759beda223,
    0x7edcfd141b522c78,
    0x4e5070f17c26681c,
    0xe696cac15815f3bc,
    0x35d2a64b3bb481a7,
    0x800cff29fe7dfdf6,
    0x1ed9fac3d5baa4b0,
    0x6c2663a91ef599d1,
    0x03c1199134404341,
    0xf7ad4ded69f20554,
    0xcd9d9649b61bd6ab,
    0xc8c3bde7eadb1368,
    0xd131899fb02afb65,
    0x1d18e352e1fae7f1,
    0xda39235aef7ca6c1,
    0xa1bbf5e0a8ee4f7a,
    0x91377805cf9a0b1e,
    0x3138716180bf8e5b,
    0xd9f83acbdb3ce580,
    0x0275e515d38b897e,
    0x472d3f21f0fbbcc6,
    0x2d946eb7868ea395,
    0xba3c248d21942e09,
    0xe7223645bfde3983,
    0xff64feb902e41bb1,
    0xc97741630d10d957,
    0xc3cb1722b58d4ecc,
    0xa27aec719cae0c3b,
    0x99fecb51a48c15fb,
    0x1465ac826d27332b,
    0xe1bd047ad75ebf01,
    0x79f733af941960c5,
    0x672ec96c41a3c475,
    0xc27feba6524684f3,
    0x64efd0fd75e38734,
    0xed9e60040743ae18,
    0xfb8e2993b9ef144d,
    0x38453eb10c625a81,
    0x6978480742355c12,
    0x48cf42ce14a6ee9e,
    0x1cac1fd606312dce,
    0x7b82d6ba4792e9bb,
    0x9d141c7b1f871a07,
    0x5616b80dc11c4a2e,
    0xb849c198f21fa777,
    0x7ca91801c8d9a506,
    0xb1348e487ec273ad,
    0x41b20d1e987b3a44,
    0x7460ab55a3cfbbe3,
    0x84e628034576f20a,
    0x1b87d16d897a6173,
    0x0fe27defe45d5258,
    0x83cde6b8ca3dbeb7,
    0x0c23647ed01d1119,
    0x7a362a3ea0592384,
    0xb61f40f3f1893f10,
    0x75d457d1440471dc,
    0x4558da34237035b8,
    0xdca6116587fc2043,
    0x8d9b67d3c9ab26d0,
    0x2b0b5c88ee0e2517,
    0x6fe77a382ab5da90,
    0x269cc472d9d8fe31,
    0x63c41e46faa8cb89,
    0xb7abbc771642f52f,
    0x7d1de4852f126f39,
    0xa8c6ba3024339ba0,
    0x600507d7cee888c8,
    0x8fee82c61a20afae,
    0x57a2448926d78011,
    0xfca5e72836a458f0,
    0x072bcebb8f4b4cbd,
    0x497bbe4af36d24a1,
    0x3cafe99bb769557d,
    0x12fa9ebd05a7b5a9,
    0xe8c04baa5b836bdb,
    0x4273148fac3b7905,
    0x908384812851c121,
    0xe557d3506c55b0fd,
    0x72ff996acb4f3d61,
    0x3eda0c8e64e2dc03,
    0xf0868356e6b949e9,
    0x04ead72abb0b0ffc,
    0x17a4b5135967706a,
    0xe3c8e16f04d5367f,
    0xf84f30028daf570c,
    0x1846c8fcbd3a2232,
    0x5b8120f7f6ca9108,
    0xd46fa231ecea3ea6,
    0x334d947453340725,
    0x58403966c28ad249,
    0xbed6f3a79a9f21f5,
    0x68ccb483a5fe962d,
    0xd085751b57e1315a,
    0xfed0023de52fd18e,
    0x4b0e5b5f20e6addf,
    0x1a332de96eb1ab4c,
    0xa3ce10f57b65c604,
    0x108f7ba8d62c3cd7,
    0xab07a3a11073d8e1,
    0x6b0dad1291bed56c,
    0xf2f366433532c097,
    0x2e557726b2cee0d4,
    0x0000000000000000,
    0xcb02a476de9b5029,
    0xe4e32fd48b9e7ac2,
    0x734b65ee2c84f75e,
    0x6e5386bccd7e10af,
    0x01b4fc84e7cbca3f,
    0xcfe8735c65905fd5,
    0x3613bfda0ff4c2e6,
    0x113b872c31e7f6e8,
    0x2fe18ba255052aeb,
    0xe974b72ebc48a1e4,
    0x0abc5641b89d979b,
    0xb46aa5e62202b66e,
    0x44ec26b0c4bbff87,
    0xa6903b5b27a503c7,
    0x7f680190fc99e647,
    0x97a84a3aa71a8d9c,
    0xdd12ede16037ea7c,
    0xc554251ddd0dc84e,
    0x88c54c7d956be313,
    0x4d91696048662b5d,
    0xb08072cc9909b992,
    0xb5de5962c5c97c51,
    0x81b803ad19b637c9,
    0xb2f597d94a8230ec,
    0x0b08aac55f565da4,
    0xf1327fd2017283d6,
    0xad98919e78f35e63,
    0x6ab9519676751f53,
    0x24e921670a53774f,
    0xb9fd3d1c15d46d48,
    0x92f66194fbda485f,
    0x5a35dc7311015b37,
    0xded3f4705477a93d,
    0xc00a0eb381cd0d8d,
    0xbb88d809c65fe436,
    0x16104997beacba55,
    0x21b70ac95693b28c,
    0x59f4c5e225411876,
    0xd5db5eb50b21f499,
    0x55d7a19cf55c096f,
    0xa97246b4c3f8519f,
    0x8552d487a2bd3835,
    0x54635d181297c350,
    0x23c2efdc85183bf2,
    0x9f61f96ecc0c9379,
    0x534893a39ddc8fed,
    0x5edf0b59aa0a54cb,
    0xac2c6d1a9f38945c,
    0xd7aebba0d8aa7de7,
    0x2abfa00c09c5ef28,
    0xd84cc64f3cf72fbf,
    0x2003f64db15878b3,
    0xa724c7dfc06ec9f8,
    0x069f323f68808682,
    0xcc296acd51d01c94,
    0x055e2bae5cc0c5c3,
    0x6270e2c21d6301b6,
    0x3b842720382219c0,
    0xd2f0900e846ab824,
    0x52fc6f277a1745d2,
    0xc6953c8ce94d8b0f,
    0xe009f8fe3095753e,
    0x655b2c7992284d0b,
    0x984a37d54347dfc4,
    0xeab5aebf8808e2a5,
    0x9a3fd2c090cc56ba,
    0x9ca0e0fff84cd038,
    0x4c2595e4afade162,
    0xdf6708f4b3bc6302,
    0xbf620f237d54ebca,
    0x93429d101c118260,
    0x097d4fd08cddd4da,
    0x8c2f9b572e60ecef,
    0x708a7c7f18c4b41f,
    0x3a30dba4dfe9d3ff,
    0x4006f19a7fb0f07b,
    0x5f6bf7dd4dc19ef4,
    0x1f6d064732716e8f,
    0xf9fbcc866a649d33,
    0x308c8de567744464,
    0x8971b0f972a0292c,
    0xd61a47243f61b7d8,
    0xefeb8511d4c82766,
    0x961cb6be40d147a3,
    0xaab35f25f7b812de,
    0x76154e407044329d,
    0x513d76b64e570693,
    0xf3479ac7d2f90aa8,
    0x9b8b2e4477079c85,
    0x297eb99d3d85ac69,
  },
  {
    0x3ef29d249b2c0a19,
    0xe9e16322b6f8622f,
    0x5536994047757f7a,
    0x9f4d56d5a47b0b33,
    0x822567466aa1174c,
    0xb8f5057deb082fb2,
    0xcc48c10bf4475f53,
    0x373088d4275dec3a,
    0x968f4325180aed10,
    0x173d232cf7016151,
    0xae4ed09f946fcc13,
    0xfd4b4741c4539873,
    0x1b5b3f0dd9933765,
    0x2ffcb0967b644052,
    0xe02376d20a89840c,
    0xa3ae3a70329b18d7,
    0x419cbd2335de8526,
    0xfafebf115b7c3199,
    0x0397074f85aa9b0d,
    0xc58ad4fb4836b970,
    0xbec60be3fc4104a8,
    0x1eff36dc4b708772,
    0x131fdc33ed8453b6,
    0x0844e33e341764d3,
    0x0ff11b6eab38cd39,
    0x64351f0a7761b85a,
    0x3b5694f509cfba0e,
    0x30857084b87245d0,
    0x47afb3bd2297ae3c,
    0xf2ba5c2f6f6b554a,
    0x74bdc4761f4f70e1,
    0xcfdfc64471edc45e,
    0xe610784c1dc0af16,
    0x7aca29d63c113f28,
    0x2ded411776a859af,
    0xac5f211e99a3d5ee,
    0xd484f949a87ef33b,
    0x3ce36ca596e013e4,
    0xd120f0983a9d432c,
    0x6bc40464dc597563,
    0x69d5f5e5d1956c9e,
    0x9ae95f043698bb24,
    0xc9ecc8da66a4ef44,
    0xd69508c8a5b2eac6,
    0xc40c2235c0503b80,
    0x38c193ba8c652103,
    0x1ceec75d46bc9e8f,
    0xd331011937515ad1,
    0xd8e2e56886eca50f,
    0xb137108d5779c991,
    0x709f3b6905ca4206,
    0x4feb50831680caef,
    0xec456af3241bd238,
    0x58d673afe181abbe,
    0x242f54e7cad9bf8c,
    0x0211f1810dcc19fd,
    0x90bc4dbb0f43c60a,
    0x9518446a9da0761d,
    0xa1bfcbf13f57012a,
    0x2bde4f8961e172b5,
    0x27b853a84f732481,
    0xb0b1e643df1f4b61,
    0x18cc38425c39ac68,
    0xd2b7f7d7bf37d821,
    0x3103864a3014c720,
    0x14aa246372abfa5c,
    0x6e600db54ebac574,
    0x394765740403a3f3,
    0x09c215f0bc71e623,
    0x2a58b947e987f045,
    0x7b4cdf18b477bdd8,
    0x9709b5eb906c6fe0,
    0x73083c268060d90b,
    0xfedc400e41f9037e,
    0x284948c6e44be9b8,
    0x728ecae808065bfb,
    0x06330e9e17492b1a,
    0x5950856169e7294e,
    0xbae4f4fce6c4364f,
    0xca7bcf95e30e7449,
    0x7d7fd186a33e96c2,
    0x52836110d85ad690,
    0x4dfaa1021b4cd312,
    0x913abb75872544fa,
    0xdd46ecb9140f1518,
    0x3d659a6b1e869114,
    0xc23f2cabd719109a,
    0xd713fe062dd46836,
    0xd0a60656b2fbc1dc,
    0x221c5a79dd909496,
    0xefd26dbca1b14935,
    0x0e77eda0235e4fc9,
    0xcbfd395b6b68f6b9,
    0x0de0eaefa6f4d4c4,
    0x0422ff1f1a8532e7,
    0xf969b85eded6aa94,
    0x7f6e2007aef28f3f,
    0x3ad0623b81a938fe,
    0x6624ee8b7aada1a7,
    0xb682e8ddc856607b,
    0xa78cc56f281e2a30,
    0xc79b257a45faa08d,
    0x5b4174e0642b30b3,
    0x5f638bff7eae0254,
    0x4bc9af9c0c05f808,
    0xce59308af98b46ae,
    0x8fc58da9cc55c388,
    0x803496c7676d0eb1,
    0xf33caae1e70dd7ba,
    0xbb6202326ea2b4bf,
    0xd5020f87201871cb,
    0x9d5ca754a9b712ce,
    0x841669d87de83c56,
    0x8a6184785eb6739f,
    0x420bba6cb0741e2b,
    0xf12d5b60eac1ce47,
    0x76ac35f71283691c,
    0x2c6bb7d9fecedb5f,
    0xfccdb18f4c351a83,
    0x1f79c012c3160582,
    0xf0abadae62a74cb7,
    0xe1a5801c82ef06fc,
    0x67a21845f2cb2357,
    0x5114665f5df04d9d,
    0xbf40fd2d74278658,
    0xa0393d3fb73183da,
    0x05a409d192e3b017,
    0xa9fb28cf0b4065f9,
    0x25a9a22942bf3d7c,
    0xdb75e22703463e02,
    0xb326e10c5ab5d06c,
    0xe7968e8295a62de6,
    0xb973f3b3636ead42,
    0xdf571d3819c30ce5,
    0xee549b7229d7cbc5,
    0x12992afd65e2d146,
    0xf8ef4e9056b02864,
    0xb7041e134030e28b,
    0xc02edd2adad50967,
    0x932b4af48ae95d07,
    0x6fe6fb7bc6dc4784,
    0x239aacb755f61666,
    0x401a4bedbdb807d6,
    0x485ea8d389af6305,
    0xa41bc220adb4b13d,
    0x753b32b89729f211,
    0x997e584bb3322029,
    0x1d683193ceda1c7f,
    0xff5ab6c0c99f818e,
    0x16bbd5e27f67e3a1,
    0xa59d34ee25d233cd,
    0x98f8ae853b54a2d9,
    0x6df70afacb105e79,
    0x795d2e99b9bba425,
    0x8e437b6744334178,
    0x0186f6ce886682f0,
    0xebf092a3bb347bd2,
    0xbcd7fa62f18d1d55,
    0xadd9d7d011c5571e,
    0x0bd3e471b1bdffde,
    0xaa6c2f808eeafef4,
    0x5ee57d31f6c880a4,
    0xf50fa47ff044fca0,
    0x1addc9c351f5b595,
    0xea76646d3352f922,
    0x0000000000000000,
    0x85909f16f58ebea6,
    0x46294573aaf12ccc,
    0x0a5512bf39db7d2e,
    0x78dbd85731dd26d5,
    0x29cfbe086c2d6b48,
    0x218b5d36583a0f9b,
    0x152cd2adfacd78ac,
    0x83a39188e2c795bc,
    0xc3b9da655f7f926a,
    0x9ecba01b2c1d89c3,
    0x07b5f8509f2fa9ea,
    0x7ee8d6c926940dcf,
    0x36b67e1aaf3b6eca,
    0x86079859702425ab,
    0xfb7849dfd31ab369,
    0x4c7c57cc932a51e2,
    0xd96413a60e8a27ff,
    0x263ea566c715a671,
    0x6c71fc344376dc89,
    0x4a4f595284637af8,
    0xdaf314e98b20bcf2,
    0x572768c14ab96687,
    0x1088db7c682ec8bb,
    0x887075f9537a6a62,
    0x2e7a4658f302c2a2,
    0x619116dbe582084d,
    0xa87dde018326e709,
    0xdcc01a779c6997e8,
    0xedc39c3dac7d50c8,
    0xa60a33a1a078a8c0,
    0xc1a82be452b38b97,
    0x3f746bea134a88e9,
    0xa228ccbebafd9a27,
    0xabead94e068c7c04,
    0xf48952b178227e50,
    0x5cf48cb0fb049959,
    0x6017e0156de48abd,
    0x4438b4f2a73d3531,
    0x8c528ae649ff5885,
    0xb515ef924dfcfb76,
    0x0c661c212e925634,
    0xb493195cc59a7986,
    0x9cda519a21d1903e,
    0x32948105b5be5c2d,
    0x194ace8cd45f2e98,
    0x438d4ca238129cdb,
    0x9b6fa9cabefe39d4,
    0x81b26009ef0b8c41,
    0xded1ebf691a58e15,
    0x4e6da64d9ee6481f,
    0x54b06f8ecf13fd8a,
    0x49d85e1d01c9e1f5,
    0xafc826511c094ee3,
    0xf698a33075ee67ad,
    0x5ac7822eec4db243,
    0x8dd47c28c199da75,
    0x89f68337db1ce892,
    0xcdce37c57c21dda3,
    0x530597de503c5460,
    0x6a42f2aa543ff793,
    0x5d727a7e73621ba9,
    0xe232875307459df1,
    0x56a19e0fc2dfe477,
    0xc61dd3b4cd9c227d,
    0xe5877f03986a341b,
    0x949eb2a415c6f4ed,
    0x6206119460289340,
    0x6380e75ae84e11b0,
    0x8be772b6d6d0f16f,
    0x50929091d596cf6d,
    0xe86795ec3e9ee0df,
    0x7cf927482b581432,
    0xc86a3e14eec26db4,
    0x7119cda78dacc0f6,
    0xe40189cd100cb6eb,
    0x92adbc3a028fdff7,
    0xb2a017c2d2d3529c,
    0x200dabf8d05c8d6b,
    0x34a78f9ba2f77737,
    0xe3b4719d8f231f01,
    0x45be423c2f5bb7c1,
    0xf71e55fefd88e55d,
    0x6853032b59f3ee6e,
    0x65b3e9c4ff073aaa,
    0x772ac3399ae5ebec,
    0x87816e97f842a75b,
    0x110e2db2e0484a4b,
    0x331277cb3dd8dedd,
    0xbd510cac79eb9fa5,
    0x352179552a91f5c7,
  },
  {
    0x05ba7bc82c9b3220,
    0x31a54665f8b65e4f,
    0xb1b651f77547f4d4,
    0x8bfa0d857ba46682,
    0x85a96c5aa16a98bb,
    0x990faef908eb79c9,
    0xa15e37a247f4a62d,
    0x76857dcd5d27741e,
    0xf8c50b800a1820bc,
    0xbe65dcb201f7a2b4,
    0x666d1b986f9426e7,
    0x4cc921bf53c4e648,
    0x95410a0f93d9ca42,
    0x20cdccaa647ba4ef,
    0x429a4060890a1871,
    0x0c4ea4f69b32b38b,
    0xccda362dde354cd3,
    0x96dc23bc7c5b2fa9,
    0xc309bb68aa851ab3,
    0xd26131a73648e013,
    0x021dc52941fc4db2,
    0xcd5adab7704be48a,
    0xa77965d984ed71e6,
    0x32386fd61734bba4,
    0xe82d6dd538ab7245,
    0x5c2147ea6177b4b1,
    0x5da1ab70cf091ce8,
    0xac907fce72b8bdff,
    0x57c85dfd972278a8,
    0xa4e44c6a6b6f940d,
    0x3851995b4f1fdfe4,
    0x62578ccaed71bc9e,
    0xd9882bb0c01d2c0a,
    0x917b9d5d113c503b,
    0xa2c31e11a87643c6,
    0xe463c923a399c1ce,
    0xf71686c57ea876dc,
    0x87b4a973e096d509,
    0xaf0d567d9d3a5814,
    0xb40c2a3f59dcc6f4,
    0x3602f88495d121dd,
    0xd3e1dd3d9836484a,
    0xf945e71aa46688e5,
    0x7518547eb2a591f5,
    0x9366587450c01d89,
    0x9ea81018658c065b,
    0x4f54080cbc4603a3,
    0x2d0384c65137bf3d,
    0xdc325078ec861e2a,
    0xea30a8fc79573ff7,
    0x214d2030ca050cb6,
    0x65f0322b8016c30c,
    0x69be96dd1b247087,
    0xdb95ee9981e161b8,
    0xd1fc1814d9ca05f8,
    0x820ed2bbcc0de729,
    0x63d76050430f14c7,
    0x3bccb0e8a09d3a0f,
    0x8e40764d573f54a2,
    0x39d175c1e16177bd,
    0x12f5a37c734f1f4b,
    0xab37c12f1fdfc26d,
    0x5648b167395cd0f1,
    0x6c04ed1537bf42a7,
    0xed97161d14304065,
    0x7d6c67daab72b807,
    0xec17fa87ba4ee83c,
    0xdfaf79cb0304fbc1,
    0x733f060571bc463e,
    0x78d61c1287e98a27,
    0xd07cf48e77b4ada1,
    0xb9c262536c90dd26,
    0xe2449b5860801605,
    0x8fc09ad7f941fcfb,
    0xfad8cea94be46d0e,
    0xa343f28b0608eb9f,
    0x9b126bd04917347b,
    0x9a92874ae7699c22,
    0x1b017c42c4e69ee0,
    0x3a4c5c720ee39256,
    0x4b6e9f5e3ea399da,
    0x6ba353f45ad83d35,
    0xe7fee0904c1b2425,
    0x22d009832587e95d,
    0x842980c00f1430e2,
    0xc6b3c0a0861e2893,
    0x087433a419d729f2,
    0x341f3dadd42d6c6f,
    0xee0a3faefbb2a58e,
    0x4aee73c490dd3183,
    0xaab72db5b1a16a34,
    0xa92a04065e238fdf,
    0x7b4b35a1686b6fcc,
    0x6a23bf6ef4a6956c,
    0x191cb96b851ad352,
    0x55d598d4d6de351a,
    0xc9604de5f2ae7ef3,
    0x1ca6c2a3a981e172,
    0xde2f9551ad7a5398,
    0x3025aaff56c8f616,
    0x15521d9d1e2860d9,
    0x506fe31cfa45073a,
    0x189c55f12b647b0b,
    0x0180ec9aae7ea859,
    0x7cec8b40050c105e,
    0x2350e5198bf94104,
    0xef8ad33455cc0dd7,
    0x07a7bee16d677f92,
    0xe5e325b90de76997,
    0x5a061591a26e637a,
    0xb611ef1618208b46,
    0x09f4df3eb7a981ab,
    0x1ebb078ae87dacc0,
    0xb791038cb65e231f,
    0x0fd38d4574b05660,
    0x67edf702c1ea8ebe,
    0xba5f4be0831238cd,
    0xe3c477c2cefebe5c,
    0x0dce486c354c1bd2,
    0x8c5db36416c31910,
    0x26ea9ed1a7627324,
    0x039d29b3ef82e5eb,
    0x9f28fc82cbf2ae02,
    0xa8aae89cf05d2786,
    0x431aacfa2774b028,
    0xcf471f9e31b7a938,
    0x581bd0b8e3922ec8,
    0xbc78199b400bef06,
    0x90fb71c7bf42f862,
    0x1f3beb1046030499,
    0x683e7a47b55ad8de,
    0x988f4263a695d190,
    0xd808c72a6e638453,
    0x0627527bc319d7cb,
    0xebb04466d72997ae,
    0xe67e0c0ae2658c7c,
    0x14d2f107b056c880,
    0x7122c32c30400b8c,
    0x8a7ae11fd5dacedb,
    0xa0dedb38e98a0e74,
    0xad109354dcc615a6,
    0x0be91a17f655cc19,
    0x8ddd5ffeb8bdb149,
    0xbfe53028af890aed,
    0xd65ba6f5b4ad7a6a,
    0x7956f0882997227e,
    0x10e8665532b352f9,
    0x0e5361dfdacefe39,
    0xcec7f3049fc90161,
    0xff62b561677f5f2e,
    0x975ccf26d22587f0,
    0x51ef0f86543baf63,
    0x2f1e41ef10cbf28f,
    0x52722635bbb94a88,
    0xae8dbae73344f04d,
    0x410769d36688fd9a,
    0xb3ab94de34bbb966,
    0x801317928df1aa9b,
    0xa564a0f0c5113c54,
    0xf131d4bebdb1a117,
    0x7f71a2f3ea8ef5b5,
    0x40878549c8f655c3,
    0x7ef14e6944f05dec,
    0xd44663dcf55137d8,
    0xf2acfd0d523344fc,
    0x0000000000000000,
    0x5fbc6e598ef5515a,
    0x16cf342ef1aa8532,
    0xb036bd6ddb395c8d,
    0x13754fe6dd31b712,
    0xbbdfa77a2d6c9094,
    0x89e7c8ac3a582b30,
    0x3c6b0e09cdfa459d,
    0xc4ae0589c7e26521,
    0x49735a777f5fd468,
    0xcafd64561d2c9b18,
    0xda1502032f9fc9e1,
    0x8867243694268369,
    0x3782141e3baf8984,
    0x9cb5d53124704be9,
    0xd7db4a6f1ad3d233,
    0xa6f989432a93d9bf,
    0x9d3539ab8a0ee3b0,
    0x53f2caaf15c7e2d1,
    0x6e19283c76430f15,
    0x3debe2936384edc4,
    0x5e3c82c3208bf903,
    0x33b8834cb94a13fd,
    0x6470deb12e686b55,
    0x359fd1377a53c436,
    0x61caa57902f35975,
    0x043a975282e59a79,
    0xfd7f70482683129c,
    0xc52ee913699ccd78,
    0x28b9ff0e7dac8d1d,
    0x5455744e78a09d43,
    0xcb7d88ccb3523341,
    0x44bd121b4a13cfba,
    0x4d49cd25fdba4e11,
    0x3e76cb208c06082f,
    0x3ff627ba2278a076,
    0xc28957f204fbb2ea,
    0x453dfe81e46d67e3,
    0x94c1e6953da7621b,
    0x2c83685cff491764,
    0xf32c1197fc4deca5,
    0x2b24d6bd922e68f6,
    0xb22b78449ac5113f,
    0x48f3b6edd1217c31,
    0x2e9ead75beb55ad6,
    0x174fd8b45fd42d6b,
    0x4ed4e4961238abfa,
    0x92e6b4eefebeb5d0,
    0x46a0d7320bef8208,
    0x47203ba8a5912a51,
    0x24f75bf8e69e3e96,
    0xf0b1382413cf094e,
    0xfee259fbc901f777,
    0x276a724b091cdb7d,
    0xbdf8f501ee75475f,
    0x599b3c224dec8691,
    0x6d84018f99c1eafe,
    0x7498b8e41cdb39ac,
    0xe0595e71217c5bb7,
    0x2aa43a273c50c0af,
    0xf50b43ec3f543b6e,
    0x838e3e2162734f70,
    0xc09492db4507ff58,
    0x72bfea9fdfc2ee67,
    0x11688acf9ccdfaa0,
    0x1a8190d86a9836b9,
    0x7acbd93bc615c795,
    0xc7332c3a286080ca,
    0x863445e94ee87d50,
    0xf6966a5fd0d6de85,
    0xe9ad814f96d5da1c,
    0x70a22fb69e3ea3d5,
    0x0a69f68d582b6440,
    0xb8428ec9c2ee757f,
    0x604a49e3ac8df12c,
    0x5b86f90b0c10cb23,
    0xe1d9b2eb8f02f3ee,
    0x29391394d3d22544,
    0xc8e0a17f5cd0d6aa,
    0xb58cc6a5f7a26ead,
    0x8193fb08238f02c2,
    0xd5c68f465b2f9f81,
    0xfcff9cd288fdbac5,
    0x77059157f359dc47,
    0x1d262e3907ff492b,
    0xfb582233e59ac557,
    0xddb2bce242f8b673,
    0x2577b76248e096cf,
    0x6f99c4a6d83da74c,
    0xc1147e41eb795701,
    0xf48baf76912a9337,
  },
  {
    0x45b268a93acde4cc,
    0xaf7f0be884549d08,
    0x048354b3c1468263,
    0x925435c2c80efed2,
    0xee4e37f27fdffba7,
    0x167a33920c60f14d,
    0xfb123b52ea03e584,
    0x4a0cab53fdbb9007,
    0x9deaf6380f788a19,
    0xcb48ec558f0cb32a,
    0xb59dc4b2d6fef7e0,
    0xdcdbca22f4f3ecb6,
    0x11df5813549a9c40,
    0xe33fdedf568aced3,
    0xa0c1c8124322e9c3,
    0x07a56b8158fa6d0d,
    0x77279579b1e1f3dd,
    0xd9b18b74422ac004,
    0xb8ec2d9fffabc294,
    0xf4acf8a82d75914f,
    0x7bbf69b1ef2b6878,
    0xc4f62faf487ac7e1,
    0x76ce809cc67e5d0c,
    0x6711d88f92e4c14c,
    0x627b99d9243dedfe,
    0x234aa5c3dfb68b51,
    0x909b1f15262dbf6d,
    0x4f66ea054b62bcb5,
    0x1ae2cf5a52aa6ae8,
    0xbea053fbd0ce0148,
    0xed6808c0e66314c9,
    0x43fe16cd15a82710,
    0xcd049231a06970f6,
    0xe7bc8a6c97cc4cb0,
    0x337ce835fcb3b9c0,
    0x65def2587cc780f3,
    0x52214ede4132bb50,
    0x95f15e4390f493df,
    0x870839625dd2e0f1,
    0x41313c1afb8b66af,
    0x91720af051b211bc,
    0x477d427ed4eea573,
    0x2e3b4ceef6e3be25,
    0x82627834eb0bcc43,
    0x9c03e3dd78e724c8,
    0x2877328ad9867df9,
    0x14b51945e243b0f2,
    0x574b0f88f7eb97e2,
    0x88b6fa989aa4943a,
    0x19c4f068cb168586,
    0x50ee6409af11faef,
    0x7df317d5c04eaba4,
    0x7a567c5498b4c6a9,
    0xb6bbfb804f42188e,
    0x3cc22bcf3bc5cd0b,
    0xd04336eaaa397713,
    0xf02fac1bec33132c,
    0x2506dba7f0d3488d,
    0xd7e65d6bf2c31a1e,
    0x5eb9b2161ff820f5,
    0x842e0650c46e0f9f,
    0x716beb1d9e843001,
    0xa933758cab315ed4,
    0x3fe414fda2792265,
    0x27c9f1701ef00932,
    0x73a4c1ca70a771be,
    0x94184ba6e76b3d0e,
    0x40d829ff8c14c87e,
    0x0fbec3fac77674cb,
    0x3616a9634a6a9572,
    0x8f139119c25ef937,
    0xf545ed4d5aea3f9e,
    0xe802499650ba387b,
    0x6437e7bd0b582e22,
    0xe6559f89e053e261,
    0x80ad52e305288dfc,
    0x6dc55a23e34b9935,
    0xde14e0f51ad0ad09,
    0xc6390578a659865e,
    0x96d7617109487cb1,
    0xe2d6cb3a21156002,
    0x01e915e5779faed1,
    0xadb0213f6a77dcb7,
    0x9880b76eb9a1a6ab,
    0x5d9f8d248644cf9b,
    0xfd5e4536c5662658,
    0xf1c6b9fe9bacbdfd,
    0xeacd6341be9979c4,
    0xefa7221708405576,
    0x510771ecd88e543e,
    0xc2ba51cb671f043d,
    0x0ad482ac71af5879,
    0xfe787a045cdac936,
    0xb238af338e049aed,
    0xbd866cc94972ee26,
    0x615da6ebbd810290,
    0x3295fdd08b2c1711,
    0xf834046073bf0aea,
    0xf3099329758ffc42,
    0x1caeb13e7dcfa934,
    0xba2307481188832b,
    0x24efce42874ce65c,
    0x0e57d61fb0e9da1a,
    0xb3d1bad6f99b343c,
    0xc0757b1c893c4582,
    0x2b510db8403a9297,
    0x5c7698c1f1db614a,
    0x3e0d0118d5e68cb4,
    0xd60f488e855cb4cf,
    0xae961e0df3cb33d9,
    0x3a8e55ab14a00ed7,
    0x42170328623789c1,
    0x838b6dd19c946292,
    0x895fef7ded3b3aeb,
    0xcfcbb8e64e4a3149,
    0x064c7e642f65c3dc,
    0x3d2b3e2a4c5a63da,
    0x5bd3f340a9210c47,
    0xb474d157a1615931,
    0xac5934da1de87266,
    0x6ee365117af7765b,
    0xc86ed36716b05c44,
    0x9ba6885c201d49c5,
    0xb905387a88346c45,
    0x131072c4bab9ddff,
    0xbf49461ea751af99,
    0xd52977bc1ce05ba1,
    0xb0f785e46027db52,
    0x546d30ba6e57788c,
    0x305ad707650f56ae,
    0xc987c682612ff295,
    0xa5ab8944f5fbc571,
    0x7ed528e759f244ca,
    0x8ddcbbce2c7db888,
    0xaa154abe328db1ba,
    0x1e619be993ece88b,
    0x09f2bd9ee813b717,
    0x7401aa4b285d1cb3,
    0x21858f143195caee,
    0x48c381841398d1b8,
    0xfcb750d3b2f98889,
    0x39a86a998d1ce1b9,
    0x1f888e0ce473465a,
    0x7899568376978716,
    0x02cf2ad7ee2341bf,
    0x85c713b5b3f1a14e,
    0xff916fe12b4567e7,
    0x7c1a0230b7d10575,
    0x0c98fcc85eca9ba5,
    0xa3e7f720da9e06ad,
    0x6a6031a2bbb1f438,
    0x973e74947ed7d260,
    0x2cf4663918c0ff9a,
    0x5f50a7f368678e24,
    0x34d983b4a449d4cd,
    0x68af1b755592b587,
    0x7f3c3d022e6dea1b,
    0xabfc5f5b45121f6b,
    0x0d71e92d29553574,
    0xdffdf5106d4f03d8,
    0x081ba87b9f8c19c6,
    0xdb7ea1a3ac0981bb,
    0xbbca12ad66172dfa,
    0x79704366010829c7,
    0x179326777bff5f9c,
    0x0000000000000000,
    0xeb2476a4c906d715,
    0x724dd42f0738df6f,
    0xb752ee6538ddb65f,
    0x37ffbc863df53ba3,
    0x8efa84fcb5c157e6,
    0xe9eb5c73272596aa,
    0x1b0bdabf2535c439,
    0x86e12c872a4d4e20,
    0x9969a28bce3e087a,
    0xfafb2eb79d9c4b55,
    0x056a4156b6d92cb2,
    0x5a3ae6a5debea296,
    0x22a3b026a8292580,
    0x53c85b3b36ad1581,
    0xb11e900117b87583,
    0xc51f3a4a3fe56930,
    0xe019e1edcf3621bd,
    0xec811d2591fcba18,
    0x445b7d4c4d524a1d,
    0xa8da6069dcaef005,
    0x58f5cc72309de329,
    0xd4c062596b7ff570,
    0xce22ad0339d59f98,
    0x591cd99747024df8,
    0x8b90c5aa03187b54,
    0xf663d27fc356d0f0,
    0xd8589e9135b56ed5,
    0x35309651d3d67a1c,
    0x12f96721cd26732e,
    0xd28c1c3d441a36ac,
    0x492a946164077f69,
    0x2d1d73dc6f5f514b,
    0x6f0a70f40d68d88a,
    0x60b4b30eca1eac41,
    0xd36509d83385987d,
    0x0b3d97490630f6a8,
    0x9eccc90a96c46577,
    0xa20ee2c5ad01a87c,
    0xe49ab55e0e70a3de,
    0xa4429ca182646ba0,
    0xda97b446db962f6a,
    0xcced87d4d7f6de27,
    0x2ab8185d37a53c46,
    0x9f25dcefe15bcba6,
    0xc19c6ef9fea3eb53,
    0xa764a3931bd884ce,
    0x2fd2590b817c10f4,
    0x56a21a6d80743933,
    0xe573a0bb79ef0d0f,
    0x155c0ca095dc1e23,
    0x6c2c4fc694d437e4,
    0x10364df623053291,
    0xdd32dfc7836c4267,
    0x03263f3299bcef6e,
    0x66f8cd6ae57b6f9d,
    0x8c35ae2b5be21659,
    0x31b3c2e21290f87f,
    0x93bd2027bf915003,
    0x69460e90220d1b56,
    0x299e276fae19d328,
    0x63928c3c53a2432f,
    0x7082fef8e91b9ed0,
    0xbc6f792c3eed40f7,
    0x4c40d537d2de53db,
    0x75e8bfae5fc2b262,
    0x4da9c0d2a541fd0a,
    0x4e8fffe03cfd1264,
    0x2620e495696fa7e3,
    0xe1f0f408b8a98f6c,
    0xd1aa230fdda6d9c2,
    0xc7d0109dd1c6288f,
    0x8a79d04f7487d585,
    0x4694579ba3710ba2,
    0x38417f7cfa834f68,
    0x1d47a4db0a5007e5,
    0x206c9af1460a643f,
    0xa128ddf734bd4712,
    0x8144470672b7232d,
    0xf2e086cc02105293,
    0x182de58dbc892b57,
    0xcaa1f9b0f8931dfb,
    0x6b892447cc2e5ae9,
    0xf9dd11850420a43b,
    0x4be5beb68a243ed6,
    0x5584255f19c8d65d,
    0x3b67404e633fa006,
    0xa68db6766c472a1f,
    0xf78ac79ab4c97e21,
    0xc353442e1080aaec,
    0x9a4f9db95782e714,
  },
  {
    0xc811a8058c3f55de,
    0x65f5b43196b50619,
    0xf74f96b1d6706e43,
    0x859d1e8bcb43d336,
    0x5aab8a85ccfa3d84,
    0xf9c7bf99c295fcfd,
    0xa21fd5a1de4b630f,
    0xcdb3ef763b8b456d,
    0x803f59f87cf7c385,
    0xb27c73be5f31913c,
    0x98e3ac6633b04821,
    0xbf61674c26b8f818,
    0x0ffbc995c4c130c8,
    0xaaa0862010761a98,
    0x6057f342210116aa,
    0xf63c760c0654cc35,
    0x2ddb45cc667d9042,
    0xbcf45a964bd40382,
    0x68e8a0c3ef3c6f3d,
    0xa7bd92d269ff73bc,
    0x290ae20201ed2287,
    0xb7de34cde885818f,
    0xd901eea7dd61059b,
    0xd6fa273219a03553,
    0xd56f1ae874cccec9,
    0xea31245c2e83f554,
    0x7034555da07be499,
    0xce26d2ac56e7bef7,
    0xfd161857a5054e38,
    0x6a0e7da4527436d1,
    0x5bd86a381cde9ff2,
    0xcaf7756231770c32,
    0xb09aaed9e279c8d0,
    0x5def1091c60674db,
    0x111046a2515e5045,
    0x23536ce4729802fc,
    0xc50cbcf7f5b63cfa,
    0x73a16887cd171f03,
    0x7d2941afd9f28dbd,
    0x3f5e3eb45a4f3b9d,
    0x84eefe361b677140,
    0x3db8e3d3e7076271,
    0x1a3a28f9f20fd248,
    0x7ebc7c75b49e7627,
    0x74e5f293c7eb565c,
    0x18dcf59e4f478ba4,
    0x0c6ef44fa9adcb52,
    0xc699812d98dac760,
    0x788b06dc6e469d0e,
    0xfc65f8ea7521ec4e,
    0x30a5f7219e8e0b55,
    0x2bec3f65bca57b6b,
    0xddd04969baf1b75e,
    0x99904cdbe394ea57,
    0x14b201d1e6ea40f6,
    0xbbb0c08241284add,
    0x50f20463bf8f1dff,
    0xe8d7f93b93cbacb8,
    0x4d8cb68e477c86e8,
    0xc1dd1b3992268e3f,
    0x7c5aa11209d62fcb,
    0x2f3d98abdb35c9ae,
    0x671369562bfd5ff5,
    0x15c1e16c36cee280,
    0x1d7eb2edf8f39b17,
    0xda94d37db00dfe01,
    0x877bc3ec760b8ada,
    0xcb8495dfe153ae44,
    0x05a24773b7b410b3,
    0x12857b783c32abdf,
    0x8eb770d06812513b,
    0x536739b9d2e3e665,
    0x584d57e271b26468,
    0xd789c78fc9849725,
    0xa935bbfa7d1ae102,
    0x8b1537a3dfa64188,
    0xd0cd5d9bc378de7a,
    0x4ac82c9a4d80cfb7,
    0x42777f1b83bdb620,
    0x72d2883a1d33bd75,
    0x5e7a2d4bab6a8f41,
    0xf4daab6bbb1c95d9,
    0x905cffe7fd8d31b6,
    0x83aa6422119b381f,
    0xc0aefb8442022c49,
    0xa0f908c663033ae3,
    0xa428af0804938826,
    0xade41c341a8a53c7,
    0xae7121ee77e6a85d,
    0xc47f5c4a25929e8c,
    0xb538e9aa55cdd863,
    0x06377aa9dad8eb29,
    0xa18ae87bb3279895,
    0x6edfda6a35e48414,
    0x6b7d9d19825094a7,
    0xd41cfa55a4e86cbf,
    0xe5caedc9ea42c59c,
    0xa36c351c0e6fc179,
    0x5181e4de6fabbf89,
    0xfff0c530184d17d4,
    0x9d41eb1584045892,
    0x1c0d525028d73961,
    0xf178ec180ca8856a,
    0x9a0571018ef811cd,
    0x4091a27c3ef5efcc,
    0x19af15239f6329d2,
    0x347450eff91eb990,
    0xe11b4a078dd27759,
    0xb9561de5fc601331,
    0x912f1f5a2da993c0,
    0x1654dcb65ba2191a,
    0x3e2dde098a6b99eb,
    0x8a66d71e0f82e3fe,
    0x8c51adb7d55a08d7,
    0x4533e50f8941ff7f,
    0x02e6dd67bd4859ec,
    0xe068aaba5df6d52f,
    0xc24826e3ff4a75a5,
    0x6c39070d88acddf8,
    0x6486548c4691a46f,
    0xd1bebd26135c7c0c,
    0xb30f93038f15334a,
    0x82d9849fc1bf9a69,
    0x9c320ba85420fae4,
    0xfa528243aff90767,
    0x9ed4d6cfe968a308,
    0xb825fd582c44b147,
    0x9b7691bc5edcb3bb,
    0xc7ea619048fe6516,
    0x1063a61f817af233,
    0x47d538683409a693,
    0x63c2ce984c6ded30,
    0x2a9fdfd86c81d91d,
    0x7b1e3b06032a6694,
    0x666089ebfbd9fd83,
    0x0a598ee67375207b,
    0x07449a140afc495f,
    0x2ca8a571b6593234,
    0x1f986f8a45bbc2fb,
    0x381aa4a050b372c2,
    0x5423a3add81faf3a,
    0x17273c0b8b86bb6c,
    0xfe83258dc869b5a2,
    0x287902bfd1c980f1,
    0xf5a94bd66b3837af,
    0x88800a79b2caba12,
    0x55504310083b0d4c,
    0xdf36940e07b9eeb2,
    0x04d1a7ce6790b2c5,
    0x612413fff125b4dc,
    0x26f12b97c52c124f,
    0x86082351a62f28ac,
    0xef93632f9937e5e7,
    0x3507b052293a1be6,
    0xe72c30ae570a9c70,
    0xd3586041ae1425e0,
    0xde4574b3d79d4cc4,
    0x92ba228040c5685a,
    0xf00b0ca5dc8c271c,
    0xbe1287f1f69c5a6e,
    0xf39e317fb1e0dc86,
    0x495d114020ec342d,
    0x699b407e3f18cd4b,
    0xdca3a9d46ad51528,
    0x0d1d14f279896924,
    0x0000000000000000,
    0x593eb75fa196c61e,
    0x2e4e78160b116bd8,
    0x6d4ae7b058887f8e,
    0xe65fd013872e3e06,
    0x7a6ddbbbd30ec4e2,
    0xac97fc89caaef1b1,
    0x09ccb33c1e19dbe1,
    0x89f3eac462ee1864,
    0x7770cf49aa87adc6,
    0x56c57eca6557f6d6,
    0x03953dda6d6cfb9a,
    0x36928d884456e07c,
    0x1eeb8f37959f608d,
    0x31d6179c4eaaa923,
    0x6fac3ad7e5c02662,
    0x43049fa653991456,
    0xabd3669dc052b8ee,
    0xaf02c153a7c20a2b,
    0x3ccb036e3723c007,
    0x93c9c23d90e1ca2c,
    0xc33bc65e2f6ed7d3,
    0x4cff56339758249e,
    0xb1e94e64325d6aa6,
    0x37e16d359472420a,
    0x79f8e661be623f78,
    0x5214d90402c74413,
    0x482ef1fdf0c8965b,
    0x13f69bc5ec1609a9,
    0x0e88292814e592be,
    0x4e198b542a107d72,
    0xccc00fcbebafe71b,
    0x1b49c844222b703e,
    0x2564164da840e9d5,
    0x20c6513e1ff4f966,
    0xbac3203f910ce8ab,
    0xf2edd1c261c47ef0,
    0x814cb945acd361f3,
    0x95feb8944a392105,
    0x5c9cf02c1622d6ad,
    0x971865f3f77178e9,
    0xbd87ba2b9bf0a1f4,
    0x444005b259655d09,
    0xed75be48247fbc0b,
    0x7596122e17cff42a,
    0xb44b091785e97a15,
    0x966b854e2755da9f,
    0xeee0839249134791,
    0x32432a4623c652b9,
    0xa8465b47ad3e4374,
    0xf8b45f2412b15e8b,
    0x2417f6f078644ba3,
    0xfb2162fe7fdda511,
    0x4bbbcc279da46dc1,
    0x0173e0bdd024a276,
    0x22208c59a2bca08a,
    0x8fc4906db836f34d,
    0xe4b90d743a6667ea,
    0x7147b5e0705f46ef,
    0x2782cb2a1508b039,
    0xec065ef5f45b1e7d,
    0x21b5b183cfd05b10,
    0xdbe733c060295c77,
    0x9fa73672394c017e,
    0xcf55321186c31c81,
    0xd8720e1a0d45a7ed,
    0x3b8f997a3ddf8958,
    0x3afc79c7edfb2b2e,
    0xe9a4198643ef0ece,
    0x5f09cdf67b4e2d37,
    0x4f6a6be9fa34df04,
    0xb6add47038a123f9,
    0x8d224d0a057eaaa1,
    0xc96248b85c1bf7a8,
    0xe3fd9760309a2eb5,
    0x0b2a6e5ba351820d,
    0xeb42c4e1fea75722,
    0x948d58299a1d8373,
    0x7fcf9cc864bad451,
    0xa55b4fb5d4b72a50,
    0x08bf5381ce3d7997,
    0x46a6d8d5e42d04e5,
    0xd22b80fc7e308796,
    0x57b69e77b57354a0,
    0x3969441d8097d0b4,
    0x3330cafbf3e2f0cf,
    0xe28e77dde0be8cc3,
    0x62b12e259c494f46,
    0xa6ce726fb9dbd1ca,
    0x41e242c1eed14dba,
    0x76032ff47aa30fb0,
  },
  {
    0xe6f87e5c5b711fd0,
    0x258377800924fa16,
    0xc849e07e852ea4a8,
    0x5b4686a18f06c16a,
    0x0b32e9a2d77b416e,
    0xabda37a467815c66,
    0xf61796a81a686676,
    0xf5dc0b706391954b,
    0x4862f38db7e64bf1,
    0xff5c629a68bd85c5,
    0xcb827da6fcd75795,
    0x66d36daf69b9f089,
    0x356c9f74483d83b0,
    0x7cbcecb1238c99a1,
    0x36a702ac31c4708d,
    0x9eb6a8d02fbcdfd6,
    0x8b19fa51e5b3ae37,
    0x9ccfb5408a127d0b,
    0xbc0c78b508208f5a,
    0xe533e3842288eced,
    0xcec2c7d377c15fd2,
    0xec7817b6505d0f5e,
    0xb94cc2c08336871d,
    0x8c205db4cb0b04ad,
    0x763c855b28a0892f,
    0x588d1b79f6ff3257,
    0x3fecf69e4311933e,
    0x0fc0d39f803a18c9,
    0xee010a26f5f3ad83,
    0x10efe8f4411979a6,
    0x5dcda10c7de93a10,
    0x4a1bee1d1248e92c,
    0x53bff2db21847339,
    0xb4f50ccfa6a23d09,
    0x5fb4bc9cd84798cd,
    0xe88a2d8b071c56f9,
    0x7f7771695a756a9c,
    0xc5f02e71a0ba1ebc,
    0xa663f9ab4215e672,
    0x2eb19e22de5fbb78,
    0x0db9ce0f2594ba14,
    0x82520e6397664d84,
    0x2f031e6a0208ea98,
    0x5c7f2144a1be6bf0,
    0x7a37cb1cd16362db,
    0x83e08e2b4b311c64,
    0xcf70479bab960e32,
    0x856ba986b9dee71e,
    0xb5478c877af56ce9,
    0xb8fe42885f61d6fd,
    0x1bdd0156966238c8,
    0x622157923ef8a92e,
    0xfc97ff42114476f8,
    0x9d7d350856452ceb,
    0x4c90c9b0e0a71256,
    0x2308502dfbcb016c,
    0x2d7a03faa7a64845,
    0xf46e8b38bfc6c4ab,
    0xbdbef8fdd477deba,
    0x3aac4cebc8079b79,
    0xf09cb105e8879d0c,
    0x27fa6a10ac8a58cb,
    0x8960e7c1401d0cea,
    0x1a6f811e4a356928,
    0x90c4fb0773d196ff,
    0x43501a2f609d0a9f,
    0xf7a516e0c63f3796,
    0x1ce4a6b3b8da9252,
    0x1324752c38e08a9b,
    0xa5a864733bec154f,
    0x2bf124575549b33f,
    0xd766db15440dc5c7,
    0xa7d179e39e42b792,
    0xdadf151a61997fd3,
    0x86a0345ec0271423,
    0x38d5517b6da939a4,
    0x6518f077104003b4,
    0x02791d90a5aea2dd,
    0x88d267899c4a5d0a,
    0x930f66df0a2865c2,
    0x4ee9d4204509b08b,
    0x325538916685292a,
    0x412907bfc533a842,
    0xb27e2b62544dc673,
    0x6c5304456295e007,
    0x5af406e95351908a,
    0x1f2f3b6bc123616f,
    0xc37b09dc5255e5c6,
    0x3967d133b1fe6844,
    0x298839c7f0e711e2,
    0x409b87f71964f9a2,
    0xe938adc3db4b0719,
    0x0c0b4e47f9c3ebf4,
    0x5534d576d36b8843,
    0x4610a05aeb8b02d8,
    0x20c3cdf58232f251,
    0x6de1840dbec2b1e7,
    0xa0e8de06b0fa1d08,
    0x7b854b540d34333b,
    0x42e29a67bcca5b7f,
    0xd8a6088ac437dd0e,
    0xc63bb3a9d943ed81,
    0x21714dbd5e65a3b1,
    0x6761ede7b5eea169,
    0x2431f7c8d573abf6,
    0xd51fc685e1a3671a,
    0x5e063cd40410c92d,
    0x283ab98f2cb04002,
    0x8febc06cb2f2f790,
    0x17d64f116fa1d33c,
    0xe07359f1a99ee4aa,
    0x784ed68c74cdc006,
    0x6e2a19d5c73b42da,
    0x8712b4161c7045c3,
    0x371582e4ed93216d,
    0xace390414939f6fc,
    0x7ec5f12186223b7c,
    0xc0b094042bac16fb,
    0xf9d745379a527ebf,
    0x737c3f2ea3b68168,
    0x33e7b8d9bad278ca,
    0xa9a32a34c22ffebb,
    0xe48163ccfedfbd0d,
    0x8e5940246ea5a670,
    0x51c6ef4b842ad1e4,
    0x22bad065279c508c,
    0xd91488c218608cee,
    0x319ea5491f7cda17,
    0xd394e128134c9c60,
    0x094bf43272d5e3b3,
    0x9bf612a5a4aad791,
    0xccbbda43d26ffd0f,
    0x34de1f3c946ad250,
    0x4f5b5468995ee16b,
    0xdf9faf6fea8f7794,
    0x2648ea5870dd092b,
    0xbfc7e56d71d97c67,
    0xdde6b2ff4f21d549,
    0x3c276b463ae86003,
    0x91767b4faf86c71f,
    0x68a13e7835d4b9a0,
    0xb68c115f030c9fd4,
    0x141dd2c916582001,
    0x983d8f7ddd5324ac,
    0x64aa703fcc175254,
    0xc2c989948e02b426,
    0x3e5e76d69f46c2de,
    0x50746f03587d8004,
    0x45db3d829272f1e5,
    0x60584a029b560bf3,
    0xfbae58a73ffcdc62,
    0xa15a5e4e6cad4ce8,
    0x4ba96e55ce1fb8cc,
    0x08f9747aae82b253,
    0xc102144cf7fb471b,
    0x9f042898f3eb8e36,
    0x068b27adf2effb7a,
    0xedca97fe8c0a5ebe,
    0x778e0513f4f7d8cf,
    0x302c2501c32b8bf7,
    0x8d92ddfc175c554d,
    0xf865c57f46052f5f,
    0xeaf3301ba2b2f424,
    0xaa68b7ecbbd60d86,
    0x998f0f350104754c,
    0x0000000000000000,
    0xf12e314d34d0ccec,
    0x710522be061823b5,
    0xaf280d9930c005c1,
    0x97fd5ce25d693c65,
    0x19a41cc633cc9a15,
    0x95844172f8c79eb8,
    0xdc5432b7937684a9,
    0x9436c13a2490cf58,
    0x802b13f332c8ef59,
    0xc442ae397ced4f5c,
    0xfa1cd8efe3ab8d82,
    0xf2e5ac954d293fd1,
    0x6ad823e8907a1b7d,
    0x4d2249f83cf043b6,
    0x03cb9dd879f9f33d,
    0xde2d2f2736d82674,
    0x2a43a41f891ee2df,
    0x6f98999d1b6c133a,
    0xd4ad46cd3df436fa,
    0xbb35df50269825c0,
    0x964fdcaa813e6d85,
    0xeb41b0537ee5a5c4,
    0x0540ba758b160847,
    0xa41ae43be7bb44af,
    0xe3b8c429d0671797,
    0x819993bbee9fbeb9,
    0xae9a8dd1ec975421,
    0xf3572cdd917e6e31,
    0x6393d7dae2aff8ce,
    0x47a2201237dc5338,
    0xa32343dec903ee35,
    0x79fc56c4a89a91e6,
    0x01b28048dc5751e0,
    0x1296f564e4b7db7b,
    0x75f7188351597a12,
    0xdb6d9552bdce2e33,
    0x1e9dbb231d74308f,
    0x520d7293fdd322d9,
    0xe20a44610c304677,
    0xfeeee2d2b4ead425,
    0xca30fdee20800675,
    0x61eaca4a47015a13,
    0xe74afe1487264e30,
    0x2cc883b27bf119a5,
    0x1664cf59b3f682dc,
    0xa811aa7c1e78af5b,
    0x1d5626fb648dc3b2,
    0xb73e9117df5bce34,
    0xd05f7cf06ab56f5d,
    0xfd257f0acd132718,
    0x574dc8e676c52a9e,
    0x0739a7e52eb8aa9a,
    0x5486553e0f3cd9a3,
    0x56ff48aeaa927b7e,
    0xbe756525ad8e2d87,
    0x7d0e6cf9ffdbc841,
    0x3b1ecca31450ca99,
    0x6913be30e983e840,
    0xad511009956ea71c,
    0xb1b5b6ba2db4354e,
    0x4469bdca4e25a005,
    0x15af5281ca0f71e1,
    0x744598cb8d0e2bf2,
    0x593f9b312aa863b7,
    0xefb38a6e29a4fc63,
    0x6b6aa3a04c2d4a9d,
    0x3d95eb0ee6bf31e3,
    0xa291c3961554bfd5,
    0x18169c8eef9bcbf5,
    0x115d68bc9d4e2846,
    0xba875f18facf7420,
    0xd1edfcb8b6e23ebd,
    0xb00736f2f1e364ae,
    0x84d929ce6589b6fe,
    0x70b7a2f6da4f7255,
    0x0e7253d75c6d4929,
    0x04f23a3d574159a7,
    0x0a8069ea0b2c108e,
    0x49d073c56bb11a11,
    0x8aab7a1939e4ffd7,
    0xcd095a0b0e38acef,
    0xc9fb60365979f548,
    0x92bde697d67f3422,
    0xc78933e10514bc61,
    0xe1c1d9b975c9b54a,
    0xd2266160cf1bcd80,
    0x9a4492ed78fd8671,
    0xb3ccab2a881a9793,
    0x72cebf667fe1d088,
    0xd6d45b5d985a9427,
  },
};

__constant u64a sbob_rc64[12][8] =
{
  {
    0xe9daca1eda5b08b1,
    0x1f7c65c0812fcbeb,
    0x16d0452e43766a2f,
    0xfcc485758db84e71,
    0x0169679291e07c4b,
    0x15d360a4082a42a2,
    0x234d74cc36747605,
    0x0745a6f2596580dd,
  },
  {
    0x1a2f9da98ab5a36f,
    0xd7b5700f469de34f,
    0x982b230a72eafef3,
    0x3101b5160f5ed561,
    0x5899d6126b17b59a,
    0xcaa70adbc261b55c,
    0x56cdcbd71ba2dd55,
    0xb79bb121700479e6,
  },
  {
    0xc72fce2bacdc74f5,
    0x35843d6a28fc390a,
    0x8b1f9c525f5ef106,
    0x7b7b29b11475eaf2,
    0xb19e3590e40fe2d3,
    0x09db6260373ac9c1,
    0x31db7a8643f4b6c2,
    0xb20aba0af5961e99,
  },
  {
    0xd26615e8b3df1fef,
    0xdde4715da0e148f9,
    0x7d3c5c337e858e48,
    0x3f355e68ad1c729d,
    0x75d603ed822cd7a9,
    0xbe0352933313b7d8,
    0xf137e893a1ea5334,
    0x2ed1e384bcbe0c22,
  },
  {
    0x994747adac6bea4b,
    0x6323a96c0c413f9a,
    0x4a1086161f1c157f,
    0xbdff0f80d7359e35,
    0xa3f53a254717cdbf,
    0x161a2723b700ffdf,
    0xf563eaa97ea2567a,
    0x57fe6c7cfd581760,
  },
  {
    0xd9d33a1daeae4fae,
    0xc039307a3bc3a46f,
    0x6ca44251f9c4662d,
    0xc68ef09ab49a7f18,
    0xb4b79a1cb7a6facf,
    0xb6c6bec2661ff20a,
    0x354f903672c571bf,
    0x6e7d64467a4068fa,
  },
  {
    0xecc5aaee160ec7f4,
    0x540924bffe86ac51,
    0xc987bfe6c7c69e39,
    0xc9937a19333e47d3,
    0x372c822dc5ab9209,
    0x04054a2883694706,
    0xf34a3ca24c451735,
    0x93d4143a4d568688,
  },
  {
    0xa7c9934d425b1f9b,
    0x41416e0c02aae703,
    0x1ede369c71f8b74e,
    0x9ac4db4d3b44b489,
    0x90069b92cb2b89f4,
    0x2fc4a5d12b8dd169,
    0xd9a8515935c2ac36,
    0x1ee702bfd40d7fa4,
  },
  {
    0x9b223116545a8f37,
    0xde5f16ecd89a4c94,
    0x244289251b3a7d3a,
    0x84090de0b755d93c,
    0xb1ceb2db0b440a80,
    0x549c07a69a8a2b7b,
    0x602a1fcb92dc380e,
    0xdb5a238351446172,
  },
  {
    0x526f0580a6debeab,
    0xf3f3e4b248e52a38,
    0xdb788aff1ce74189,
    0x0361331b8ae1ff1f,
    0x4b3369af0267e79f,
    0xf452763b306c1e7a,
    0xc3b63b15d1fa9836,
    0xed9c4598fbc7b474,
  },
  {
    0xfb89c8efd09ecd7b,
    0x94fe5a63cdc60230,
    0x6107abebbb6bfad8,
    0x7966841421800120,
    0xcab948eaef711d8a,
    0x986e477d1dcdbaef,
    0x5dd86fc04a59a2de,
    0x1b2df381cda4ca6b,
  },
  {
    0xba3116f167e78e37,
    0x7ab14904b08013d2,
    0x771ddfbc323ca4cd,
    0x9b9f2130d41220f8,
    0x86cc91189def805d,
    0x5228e188aaa41de7,
    0x991bb2d9d517f4fa,
    0x20d71bf14a92bc48,
  },
};

DECLSPEC void streebog_g (u64x h[8], const u64x m[8], __local u64 (*s_sbob_sl64)[256])
{
  u64x k[8];
  u64x s[8];
  u64x t[8];

  for (int i = 0; i < 8; i++)
  {
    t[i] = h[i];
  }

  #ifdef _unroll
  #pragma unroll
  #endif
  for (int i = 0; i < 8; i++)
  {
    k[i] = SBOG_LPSti64;
  }

  for (int i = 0; i < 8; i++)
  {
    s[i] = m[i];
  }

  for (int r = 0; r < 12; r++)
  {
    for (int i = 0; i < 8; i++)
    {
      t[i] = s[i] ^ k[i];
    }

    #ifdef _unroll
    #pragma unroll
    #endif
    for (int i = 0; i < 8; i++)
    {
      s[i] = SBOG_LPSti64;
    }

    for (int i = 0; i < 8; i++)
    {
      t[i] = k[i] ^ sbob_rc64[r][i];
    }

    #ifdef _unroll
    #pragma unroll
    #endif
    for (int i = 0; i < 8; i++)
    {
      k[i] = SBOG_LPSti64;
    }
  }

  for (int i = 0; i < 8; i++)
  {
    h[i] ^= s[i] ^ k[i] ^ m[i];
  }
}

DECLSPEC void m11800m (__local u64 (*s_sbob_sl64)[256], u32 w[16], const u32 pw_len, __global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);

  /**
   * loop
   */

  u32 w0l = w[0];

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x w0r = ix_create_bft (bfs_buf, il_pos);

    const u32x w0lr = w0l | w0r;

    /**
     * GOST
     */

    u64x m[8];

    m[0] = hl32_to_64 (w[15], w[14]);
    m[1] = hl32_to_64 (w[13], w[12]);
    m[2] = hl32_to_64 (w[11], w[10]);
    m[3] = hl32_to_64 (w[ 9], w[ 8]);
    m[4] = hl32_to_64 (w[ 7], w[ 6]);
    m[5] = hl32_to_64 (w[ 5], w[ 4]);
    m[6] = hl32_to_64 (w[ 3], w[ 2]);
    m[7] = hl32_to_64 (w[ 1], w0lr );

    m[0] = swap64 (m[0]);
    m[1] = swap64 (m[1]);
    m[2] = swap64 (m[2]);
    m[3] = swap64 (m[3]);
    m[4] = swap64 (m[4]);
    m[5] = swap64 (m[5]);
    m[6] = swap64 (m[6]);
    m[7] = swap64 (m[7]);

    // state buffer (hash)

    u64x h[8];

    h[0] = INITVAL;
    h[1] = INITVAL;
    h[2] = INITVAL;
    h[3] = INITVAL;
    h[4] = INITVAL;
    h[5] = INITVAL;
    h[6] = INITVAL;
    h[7] = INITVAL;

    streebog_g (h, m, s_sbob_sl64);

    u64x z[8];

    z[0] = 0;
    z[1] = 0;
    z[2] = 0;
    z[3] = 0;
    z[4] = 0;
    z[5] = 0;
    z[6] = 0;
    z[7] = swap64 ((u64) (pw_len * 8));

    streebog_g (h, z, s_sbob_sl64);
    streebog_g (h, m, s_sbob_sl64);

    const u32x r0 = l32_from_64 (h[0]);
    const u32x r1 = h32_from_64 (h[0]);
    const u32x r2 = l32_from_64 (h[1]);
    const u32x r3 = h32_from_64 (h[1]);

    COMPARE_M_SIMD (r0, r1, r2, r3);
  }
}

DECLSPEC void m11800s (__local u64 (*s_sbob_sl64)[256], u32 w[16], const u32 pw_len, __global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);

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

  u32 w0l = w[0];

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x w0r = ix_create_bft (bfs_buf, il_pos);

    const u32x w0lr = w0l | w0r;

    /**
     * GOST
     */

    u64x m[8];

    m[0] = hl32_to_64 (w[15], w[14]);
    m[1] = hl32_to_64 (w[13], w[12]);
    m[2] = hl32_to_64 (w[11], w[10]);
    m[3] = hl32_to_64 (w[ 9], w[ 8]);
    m[4] = hl32_to_64 (w[ 7], w[ 6]);
    m[5] = hl32_to_64 (w[ 5], w[ 4]);
    m[6] = hl32_to_64 (w[ 3], w[ 2]);
    m[7] = hl32_to_64 (w[ 1], w0lr );

    m[0] = swap64 (m[0]);
    m[1] = swap64 (m[1]);
    m[2] = swap64 (m[2]);
    m[3] = swap64 (m[3]);
    m[4] = swap64 (m[4]);
    m[5] = swap64 (m[5]);
    m[6] = swap64 (m[6]);
    m[7] = swap64 (m[7]);

    // state buffer (hash)

    u64x h[8];

    h[0] = INITVAL;
    h[1] = INITVAL;
    h[2] = INITVAL;
    h[3] = INITVAL;
    h[4] = INITVAL;
    h[5] = INITVAL;
    h[6] = INITVAL;
    h[7] = INITVAL;

    streebog_g (h, m, s_sbob_sl64);

    u64x z[8];

    z[0] = 0;
    z[1] = 0;
    z[2] = 0;
    z[3] = 0;
    z[4] = 0;
    z[5] = 0;
    z[6] = 0;
    z[7] = swap64 ((u64) (pw_len * 8));

    streebog_g (h, z, s_sbob_sl64);
    streebog_g (h, m, s_sbob_sl64);

    const u32x r0 = l32_from_64 (h[0]);
    const u32x r1 = h32_from_64 (h[0]);
    const u32x r2 = l32_from_64 (h[1]);
    const u32x r3 = h32_from_64 (h[1]);

    COMPARE_S_SIMD (r0, r1, r2, r3);
  }
}

__kernel void m11800_m04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * shared lookup table
   */

  __local u64 s_sbob_sl64[8][256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_sbob_sl64[0][i] = sbob_sl64[0][i];
    s_sbob_sl64[1][i] = sbob_sl64[1][i];
    s_sbob_sl64[2][i] = sbob_sl64[2][i];
    s_sbob_sl64[3][i] = sbob_sl64[3][i];
    s_sbob_sl64[4][i] = sbob_sl64[4][i];
    s_sbob_sl64[5][i] = sbob_sl64[5][i];
    s_sbob_sl64[6][i] = sbob_sl64[6][i];
    s_sbob_sl64[7][i] = sbob_sl64[7][i];
  }

  barrier (CLK_LOCAL_MEM_FENCE);

  if (gid >= gid_max) return;

  /**
   * base
   */

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = 0;
  w[ 5] = 0;
  w[ 6] = 0;
  w[ 7] = 0;
  w[ 8] = 0;
  w[ 9] = 0;
  w[10] = 0;
  w[11] = 0;
  w[12] = 0;
  w[13] = 0;
  w[14] = 0;
  w[15] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m11800m (s_sbob_sl64, w, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m11800_m08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * shared lookup table
   */

  __local u64 s_sbob_sl64[8][256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_sbob_sl64[0][i] = sbob_sl64[0][i];
    s_sbob_sl64[1][i] = sbob_sl64[1][i];
    s_sbob_sl64[2][i] = sbob_sl64[2][i];
    s_sbob_sl64[3][i] = sbob_sl64[3][i];
    s_sbob_sl64[4][i] = sbob_sl64[4][i];
    s_sbob_sl64[5][i] = sbob_sl64[5][i];
    s_sbob_sl64[6][i] = sbob_sl64[6][i];
    s_sbob_sl64[7][i] = sbob_sl64[7][i];
  }

  barrier (CLK_LOCAL_MEM_FENCE);

  if (gid >= gid_max) return;

  /**
   * base
   */

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = pws[gid].i[ 4];
  w[ 5] = pws[gid].i[ 5];
  w[ 6] = pws[gid].i[ 6];
  w[ 7] = pws[gid].i[ 7];
  w[ 8] = 0;
  w[ 9] = 0;
  w[10] = 0;
  w[11] = 0;
  w[12] = 0;
  w[13] = 0;
  w[14] = 0;
  w[15] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m11800m (s_sbob_sl64, w, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m11800_m16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * shared lookup table
   */

  __local u64 s_sbob_sl64[8][256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_sbob_sl64[0][i] = sbob_sl64[0][i];
    s_sbob_sl64[1][i] = sbob_sl64[1][i];
    s_sbob_sl64[2][i] = sbob_sl64[2][i];
    s_sbob_sl64[3][i] = sbob_sl64[3][i];
    s_sbob_sl64[4][i] = sbob_sl64[4][i];
    s_sbob_sl64[5][i] = sbob_sl64[5][i];
    s_sbob_sl64[6][i] = sbob_sl64[6][i];
    s_sbob_sl64[7][i] = sbob_sl64[7][i];
  }

  barrier (CLK_LOCAL_MEM_FENCE);

  if (gid >= gid_max) return;

  /**
   * base
   */

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = pws[gid].i[ 4];
  w[ 5] = pws[gid].i[ 5];
  w[ 6] = pws[gid].i[ 6];
  w[ 7] = pws[gid].i[ 7];
  w[ 8] = pws[gid].i[ 8];
  w[ 9] = pws[gid].i[ 9];
  w[10] = pws[gid].i[10];
  w[11] = pws[gid].i[11];
  w[12] = pws[gid].i[12];
  w[13] = pws[gid].i[13];
  w[14] = pws[gid].i[14];
  w[15] = pws[gid].i[15];

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m11800m (s_sbob_sl64, w, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m11800_s04 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * shared lookup table
   */

  __local u64 s_sbob_sl64[8][256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_sbob_sl64[0][i] = sbob_sl64[0][i];
    s_sbob_sl64[1][i] = sbob_sl64[1][i];
    s_sbob_sl64[2][i] = sbob_sl64[2][i];
    s_sbob_sl64[3][i] = sbob_sl64[3][i];
    s_sbob_sl64[4][i] = sbob_sl64[4][i];
    s_sbob_sl64[5][i] = sbob_sl64[5][i];
    s_sbob_sl64[6][i] = sbob_sl64[6][i];
    s_sbob_sl64[7][i] = sbob_sl64[7][i];
  }

  barrier (CLK_LOCAL_MEM_FENCE);

  if (gid >= gid_max) return;

  /**
   * base
   */

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = 0;
  w[ 5] = 0;
  w[ 6] = 0;
  w[ 7] = 0;
  w[ 8] = 0;
  w[ 9] = 0;
  w[10] = 0;
  w[11] = 0;
  w[12] = 0;
  w[13] = 0;
  w[14] = 0;
  w[15] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m11800s (s_sbob_sl64, w, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m11800_s08 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * shared lookup table
   */

  __local u64 s_sbob_sl64[8][256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_sbob_sl64[0][i] = sbob_sl64[0][i];
    s_sbob_sl64[1][i] = sbob_sl64[1][i];
    s_sbob_sl64[2][i] = sbob_sl64[2][i];
    s_sbob_sl64[3][i] = sbob_sl64[3][i];
    s_sbob_sl64[4][i] = sbob_sl64[4][i];
    s_sbob_sl64[5][i] = sbob_sl64[5][i];
    s_sbob_sl64[6][i] = sbob_sl64[6][i];
    s_sbob_sl64[7][i] = sbob_sl64[7][i];
  }

  barrier (CLK_LOCAL_MEM_FENCE);

  if (gid >= gid_max) return;

  /**
   * base
   */

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = pws[gid].i[ 4];
  w[ 5] = pws[gid].i[ 5];
  w[ 6] = pws[gid].i[ 6];
  w[ 7] = pws[gid].i[ 7];
  w[ 8] = 0;
  w[ 9] = 0;
  w[10] = 0;
  w[11] = 0;
  w[12] = 0;
  w[13] = 0;
  w[14] = 0;
  w[15] = 0;

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m11800s (s_sbob_sl64, w, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}

__kernel void m11800_s16 (__global pw_t *pws, __global const kernel_rule_t *rules_buf, __global const pw_t *combs_buf, __global const bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global const u32 *bitmaps_buf_s1_a, __global const u32 *bitmaps_buf_s1_b, __global const u32 *bitmaps_buf_s1_c, __global const u32 *bitmaps_buf_s1_d, __global const u32 *bitmaps_buf_s2_a, __global const u32 *bitmaps_buf_s2_b, __global const u32 *bitmaps_buf_s2_c, __global const u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global const digest_t *digests_buf, __global u32 *hashes_shown, __global const salt_t *salt_bufs, __global const void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV0_buf, __global u32 *d_scryptV1_buf, __global u32 *d_scryptV2_buf, __global u32 *d_scryptV3_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 il_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u64 gid_max)
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);
  const u64 lsz = get_local_size (0);

  /**
   * shared lookup table
   */

  __local u64 s_sbob_sl64[8][256];

  for (u32 i = lid; i < 256; i += lsz)
  {
    s_sbob_sl64[0][i] = sbob_sl64[0][i];
    s_sbob_sl64[1][i] = sbob_sl64[1][i];
    s_sbob_sl64[2][i] = sbob_sl64[2][i];
    s_sbob_sl64[3][i] = sbob_sl64[3][i];
    s_sbob_sl64[4][i] = sbob_sl64[4][i];
    s_sbob_sl64[5][i] = sbob_sl64[5][i];
    s_sbob_sl64[6][i] = sbob_sl64[6][i];
    s_sbob_sl64[7][i] = sbob_sl64[7][i];
  }

  barrier (CLK_LOCAL_MEM_FENCE);

  if (gid >= gid_max) return;

  /**
   * base
   */

  u32 w[16];

  w[ 0] = pws[gid].i[ 0];
  w[ 1] = pws[gid].i[ 1];
  w[ 2] = pws[gid].i[ 2];
  w[ 3] = pws[gid].i[ 3];
  w[ 4] = pws[gid].i[ 4];
  w[ 5] = pws[gid].i[ 5];
  w[ 6] = pws[gid].i[ 6];
  w[ 7] = pws[gid].i[ 7];
  w[ 8] = pws[gid].i[ 8];
  w[ 9] = pws[gid].i[ 9];
  w[10] = pws[gid].i[10];
  w[11] = pws[gid].i[11];
  w[12] = pws[gid].i[12];
  w[13] = pws[gid].i[13];
  w[14] = pws[gid].i[14];
  w[15] = pws[gid].i[15];

  const u32 pw_len = pws[gid].pw_len;

  /**
   * main
   */

  m11800s (s_sbob_sl64, w, pw_len, pws, rules_buf, combs_buf, bfs_buf, tmps, hooks, bitmaps_buf_s1_a, bitmaps_buf_s1_b, bitmaps_buf_s1_c, bitmaps_buf_s1_d, bitmaps_buf_s2_a, bitmaps_buf_s2_b, bitmaps_buf_s2_c, bitmaps_buf_s2_d, plains_buf, digests_buf, hashes_shown, salt_bufs, esalt_bufs, d_return_buf, d_scryptV0_buf, d_scryptV1_buf, d_scryptV2_buf, d_scryptV3_buf, bitmap_mask, bitmap_shift1, bitmap_shift2, salt_pos, loop_pos, loop_cnt, il_cnt, digests_cnt, digests_offset);
}
