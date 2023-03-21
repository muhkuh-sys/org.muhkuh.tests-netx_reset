#ifndef __VECTORS_CM4_H__
#define __VECTORS_CM4_H__


typedef void (*PFN_HBOOT_EXEC)(unsigned long ulR0, unsigned long ulR1, unsigned long ulR2, unsigned long ulR3);
typedef void (*CM4_VECT_T)(void);


typedef struct CM4_VECTORS_STRUCT
{
	void *pvStackTop;                    /* 0x00 */

	PFN_HBOOT_EXEC pfnReset;             /* 0x04 */
	CM4_VECT_T pfnNMI;                   /* 0x08 */
	CM4_VECT_T pfnHardFault;             /* 0x0C */
	CM4_VECT_T pfnMemManageFault;        /* 0x10 */
	CM4_VECT_T pfnBusFault;              /* 0x14 */
	CM4_VECT_T pfnUsageFault;            /* 0x18 */

	unsigned long aulReserved01C[4];     /* 0x1C - 0x28 */

	CM4_VECT_T pfnSVCall;                /* 0x2C */
	CM4_VECT_T pfnDebugMonitor;          /* 0x30 */

	unsigned long ulReserved034;         /* 0x34 */

	CM4_VECT_T pfnPendSV;                /* 0x38 */
	CM4_VECT_T pfnSysTick;               /* 0x3C */

	CM4_VECT_T apfnIRQ[64];              /* 0x40 - 0xBC */
} CM4_VECTORS_T;


#endif  /* __VECTORS_CM4_H__ */
