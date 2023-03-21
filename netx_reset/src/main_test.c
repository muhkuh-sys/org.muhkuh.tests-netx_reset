#include "main_test.h"

#include <string.h>

#include "netx_io_areas.h"
#include "netx_test.h"
#include "rdy_run.h"
#include "systime.h"
#include "uprintf.h"
#include "version.h"

#include "vectors_com_intram.h"
#include "hw_irqid_arm_com.h"

/*-----------------------------------*/


static void timer_isr(void)
{
	BLINKI_HANDLE_T tBlinkiHandle;

	rdy_run_blinki_init(&tBlinkiHandle, 0x00000055, 0x00000150);
	while(1)
	{
		rdy_run_blinki(&tBlinkiHandle);
	};
}



void vector_stop(void);



static void setup_nvic(void)
{
	HOSTDEF(ptCm4ScsArea);
	unsigned long ulValue;
	unsigned int uiCnt;


	/* Set priority code point to 6: 1 bit pre-emption (nested) priority, seven bits subpriority */
	ulValue  = 0x5faUL << HOSTSRT(cm4_scs_aircr_vectkey);
	ulValue |= 6UL << HOSTSRT(cm4_scs_aircr_prigroup);
	ptCm4ScsArea->ulCm4_scs_aircr = ulValue;

	/* Set some dummy vectors. */
	tVectorsComIntram.pfnNMI            = vector_stop;
	tVectorsComIntram.pfnHardFault      = vector_stop;
	tVectorsComIntram.pfnMemManageFault = vector_stop;
	tVectorsComIntram.pfnBusFault       = vector_stop;
	tVectorsComIntram.pfnUsageFault     = vector_stop;
	tVectorsComIntram.pfnSVCall         = vector_stop;
	tVectorsComIntram.pfnDebugMonitor   = vector_stop;
	tVectorsComIntram.pfnPendSV         = vector_stop;
	tVectorsComIntram.pfnSysTick        = vector_stop;
	for(uiCnt=0; uiCnt<(sizeof(tVectorsComIntram.apfnIRQ)/sizeof(void*)); ++uiCnt)
	{
		tVectorsComIntram.apfnIRQ[uiCnt] = vector_stop;
	}

	/* Set the IRQ handler for the GPIO timer. */
	tVectorsComIntram.apfnIRQ[IRQID_ARM_GPIO_TIMER0] = timer_isr;

	/* Use the vector table in INTRAM0. */
	ptCm4ScsArea->ulCm4_scs_vtor = (unsigned long)(&tVectorsComIntram);

	__asm__("DMB");
	__asm__("DSB");

	/* Disable all IRQs. */
	ptCm4ScsArea->aulCm4_scs_nvic_icer[0] = 0xffffffffU;
	ptCm4ScsArea->aulCm4_scs_nvic_icer[1] = 0xffffffffU;
	ptCm4ScsArea->aulCm4_scs_nvic_icer[2] = 0xffffffffU;

	/* Set the IRQ priority. */
	for(uiCnt=0; uiCnt<(sizeof(ptCm4ScsArea->aulCm4_scs_nvic_ipr)/sizeof(void*)); ++uiCnt)
	{
		ptCm4ScsArea->aulCm4_scs_nvic_ipr[uiCnt] = 0;
	}

	/* Enable the GPIO timer IRQ. */
	ptCm4ScsArea->aulCm4_scs_nvic_iser[IRQID_ARM_GPIO_TIMER0 >> 5U] = 1U << (IRQID_ARM_GPIO_TIMER0&0x1fU);
}



static void clear_gpio_timer_irq(void)
{
	HOSTDEF(ptGpioComArea);
	unsigned long ulValue;


	/* Stop the counter. */
	ptGpioComArea->ulGpio_counter0_ctrl = 0;

	/* Acknowledge any pending IRQs. */
	ulValue  = HOSTMSK(gpio_irq_raw_gpio0);
	ulValue |= HOSTMSK(gpio_irq_raw_gpio1);
	ulValue |= HOSTMSK(gpio_irq_raw_gpio2);
	ulValue |= HOSTMSK(gpio_irq_raw_gpio3);
	ptGpioComArea->ulGpio_irq_raw = ulValue;
	ulValue  = HOSTMSK(gpio_cnt_irq_raw_cnt0);
	ptGpioComArea->ulGpio_cnt_irq_raw = ulValue;

	/* Deactivate GPIO pin IRQs. */
	ulValue  = HOSTMSK(gpio_irq_mask_rst_gpio0);
	ulValue |= HOSTMSK(gpio_irq_mask_rst_gpio1);
	ulValue |= HOSTMSK(gpio_irq_mask_rst_gpio2);
	ulValue |= HOSTMSK(gpio_irq_mask_rst_gpio3);
	ptGpioComArea->ulGpio_irq_mask_rst = ulValue;

	/* Deactivate the GPIO timer IRQ. */
	ulValue  = HOSTMSK(gpio_cnt_irq_mask_rst_cnt0);
	ptGpioComArea->ulGpio_cnt_irq_mask_rst = ulValue;
}



static void start_gpio_timer_irq(void)
{
	HOSTDEF(ptGpioComArea);
	unsigned long ulValue;


	/* Stop the counter. */
	ptGpioComArea->ulGpio_counter0_ctrl = 0;

	/* Count for 3 seconds.
	 * The timer runs with the CPU clock of 100MHz, which is a step of 10ns.
	 * A value of 300000000 results in 3 seconds.
	 */
	ptGpioComArea->ulGpio_counter0_max = 300000000;
	ptGpioComArea->ulGpio_counter0_cnt = 0;

	/* Start the counter. */
	ulValue  = 0U << HOSTSRT(gpio_counter0_ctrl_event_act);
	ulValue |= HOSTMSK(gpio_counter0_ctrl_once);
	ulValue |= HOSTMSK(gpio_counter0_ctrl_irq_en);
	ulValue |= HOSTMSK(gpio_counter0_ctrl_run);
	ptGpioComArea->ulGpio_counter0_ctrl = ulValue;

	/* Enable the GPIO timer IRQ. */
	ulValue  = HOSTMSK(gpio_cnt_irq_mask_set_cnt0);
	ptGpioComArea->ulGpio_cnt_irq_mask_set = ulValue;
}



/* This is an ASM function. */
void enable_irqs(void);



TEST_RESULT_T test_main(TEST_PARAMETER_T *ptTestParam);
TEST_RESULT_T test_main(TEST_PARAMETER_T *ptTestParam)
{
	NETX_RESET_PARAMETER_T *ptTestParams;


	systime_init();

//	uprintf("\f. *** netX reset by doc_bacardi@users.sourceforge.net ***\n");
//	uprintf("V" VERSION_ALL "\n\n");

	/* Switch off SYS led. */
	rdy_run_setLEDs(RDYRUN_OFF);

	/* Get the test parameter. */
	ptTestParams = (NETX_RESET_PARAMETER_T*)(ptTestParam->pvInitParams);

	/* Clear the GPIO timer IRQ. */
	clear_gpio_timer_irq();

	/* Setup the IRQ controller. */
	setup_nvic();

	enable_irqs();

	/* Setup the timer IRQ. */
	start_gpio_timer_irq();

	/* Wait for an IRQ. */
	while(1) {};
}

/*-----------------------------------*/

