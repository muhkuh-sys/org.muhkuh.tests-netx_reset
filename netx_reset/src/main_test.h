
#ifndef __MAIN_TEST_H__
#define __MAIN_TEST_H__


typedef struct NETX_RESET_PARAMETER_STRUCT
{
	unsigned long ulResetDelayTicks;
	const unsigned char *pucOptionData;
	unsigned int  sizOptionDataInBytes;
} NETX_RESET_PARAMETER_T;


#endif  /* __MAIN_TEST_H__ */

