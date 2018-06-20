/*
 * ISB.h
 *
 *  Created on: 09-Sep-2015
 *      Author: Dennis
 */

#ifndef ISB_H_
#define ISB_H_

// #include "mem/cache/prefetch/queued.hh"
// #include "params/ISBPrefetcher.hh"
#include <list>
typedef uint64_t Addr;

using namespace std;

class PS_AMC {

	public:
		unsigned long long Physical_Tag;
		bool valid;
		unsigned long long Structural_Address;
		int Confidence_Counter;
		unsigned long long Prog_Count;
		unsigned long int Eviction_Counter;
};

class Training_Unit {

	public:
		unsigned long long PC;            // Program Counter    
		unsigned long long Last_Addr;      // Last Address Accessed by PC   
		// int counter;                      // Number of elements in AMC
};

class Stream_Predictor
{
	public:
		unsigned long long Starting_Address;
		int length ;
		int Prefetch_Distance;
		
		Stream_Predictor();

};

class SP_AMC{
	public:
		unsigned long long Structural_Tag;
		bool valid;
		vector<unsigned long long> Physical_Address;


};

class Page{
	public:
	        list<PS_AMC*> offChip_Ps; 
};


		//static const int Max_Contexts = 64;   // Maximum number of cores
		static const int PMC_Size = 8192;      // Maximum size of AMC 32768,16384,8192
		static const unsigned long long SP_blk_size =64;
		//static const unsigned long long range = 16;
		
		
	        int degree;	
	        int counter;
		//list<Training_Unit*> Train_Unit[Max_Contexts];
		list<Training_Unit*> Train_Unit;
		vector<Stream_Predictor*> Stream;     
		vector<SP_AMC*> SP;
		list<PS_AMC*> PS;
		map<unsigned long long, Page*> page_map;


		void UpdateRegion(Addr address,  unsigned long long PC);
		void calculatePrefetch(uint64_t blk_addr, uint64_t PC, vector<Addr> &addresses);
		PS_AMC* freePSAMC(unsigned long long last,unsigned long long current);
		void generatePrefetch(unsigned long long struct_addr,vector<Addr> &addresses,int &set,Addr blk_addr);
		


#endif /* ISB_H_ */

