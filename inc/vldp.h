#ifndef VLDP_H
#define VLDP_H

#include "cache.h"

// L2 VLDP
// #define L2_PF_DEBUG_PRINT
#ifdef L2_PF_DEBUG_PRINT
#define L2_PF_DEBUG(x) x
#else
#define L2_PF_DEBUG(x)
#endif

#define MAX_PREFETCH_DIST 3
#define DELTA_SIZE 8
#define BLOCKS_PER_PAGE 32768
#define NUM_DHB_PAGES 16
#define NUM_OPT_ENTRIES 32768
#define NUM_DPT_ENTRIES 64
#define PREF_ERROR 0xFFFF

class DELTA_HISTORY_BUFFER {
	public:
		uint64_t valid,
			page_num,
			last_addr_offset,
			last_pref_dpt_level,
			num_access,
			mru,
			// first_hit,
			last_4_offsets[4];
		int last_4_deltas[4];

	DELTA_HISTORY_BUFFER() {
		valid = 0;
		page_num = 0;
		last_addr_offset = 0;
		last_pref_dpt_level = 1;
		num_access = 0;
		mru = 0;
		// first_hit = 0;
		for (int i=0; i<4; i++){
			last_4_deltas[i] = 0;
			last_4_offsets[i] = 0;}
	};
};

class OFFSET_PRED_TABLE {
	public:
		uint64_t first_page_offset,
			pred_offset,
			accuracy,
			valid;

	OFFSET_PRED_TABLE() {
		first_page_offset = 0;
		pred_offset = 0;
		accuracy = 0;
		valid = 0;
	};
};

class DELTA_PRED_TABLE_1 {
	public:
		int deltas[1],
			pred_delta,
			accuracy,
			mru;
	DELTA_PRED_TABLE_1(){
		for(int i=0; i<1; i++)
			deltas[i] = 0;
		pred_delta = 0;
		accuracy = 0;
		mru = 0;
	};
};

class DELTA_PRED_TABLE_2 {
	public:
		int deltas[2],
			pred_delta,
			accuracy,
			mru;
	DELTA_PRED_TABLE_2(){
		for(int i=0; i<2; i++)
			deltas[i] = 0;
		pred_delta = 0;
		accuracy = 0;
		mru = 0;
	};
};

class DELTA_PRED_TABLE_3 {
	public:
		int deltas[3],
			pred_delta,
			accuracy,
			mru;
	DELTA_PRED_TABLE_3(){
		for(int i=0; i<3; i++)
			deltas[i] = 0;
		pred_delta = 0;
		accuracy = 0;
		mru = 0;
	};
};

typedef struct 
{
    int delta;
    int dpt;
} delta_and_acc;

extern DELTA_HISTORY_BUFFER L2_DHB[NUM_CPUS][NUM_DHB_PAGES];
extern OFFSET_PRED_TABLE L2_OPT[NUM_CPUS][NUM_OPT_ENTRIES];
extern DELTA_PRED_TABLE_1 DPT_1[NUM_CPUS][NUM_DPT_ENTRIES];
extern DELTA_PRED_TABLE_2 DPT_2[NUM_CPUS][NUM_DPT_ENTRIES];
extern DELTA_PRED_TABLE_3 DPT_3[NUM_CPUS][NUM_DPT_ENTRIES];

int L2_DHB_update(uint32_t cpu,uint64_t addr);
void L2_OPT_update(uint32_t cpu, uint64_t addr, int last_block);
void L2_DPT_update(uint32_t cpu,uint64_t addr, int entry);
delta_and_acc L2_DPT_check(uint32_t cpu, int *delta, int entry);
uint64_t L2_OPT_check(uint32_t cpu, uint64_t addr);
int L2_DPT_check(uint32_t cpu, int *delta, uint64_t curr_block);
void L2_promote(uint32_t cpu, int entry, int table_num);

DELTA_HISTORY_BUFFER L2_DHB[NUM_CPUS][NUM_DHB_PAGES];
OFFSET_PRED_TABLE L2_OPT[NUM_CPUS][NUM_OPT_ENTRIES];
DELTA_PRED_TABLE_1 DPT_1[NUM_CPUS][NUM_DPT_ENTRIES];
DELTA_PRED_TABLE_2 DPT_2[NUM_CPUS][NUM_DPT_ENTRIES];
DELTA_PRED_TABLE_3 DPT_3[NUM_CPUS][NUM_DPT_ENTRIES];

#endif




