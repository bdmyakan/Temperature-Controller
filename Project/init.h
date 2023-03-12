//Retrieved from https://microcontrollerslab.com/i2c-communication-tm4c123g-tiva-c-launchpad/
#include "TM4C123GH6PM.h"

static int I2C_wait_till_done(void)
{
    while (I2C3->MCS & 1);
    return I2C3->MCS & 0xE;
}

char I2C3_Write_Multiple(int slave_address, char slave_memory_address, int count, char* data)
{
    char err;
    if (count <= 0)
        return -1;

    I2C3->MSA = slave_address << 1;
    I2C3->MDR = slave_memory_address;
    I2C3->MCS = 3;

    err = I2C_wait_till_done();
    if (err) return err;

    while (count > 1)
    {
        I2C3->MDR = *data++;
        I2C3->MCS = 1;
        err = I2C_wait_till_done();
        if (err) return err;
        count--;
    }

    I2C3->MDR = *data++;
    I2C3->MCS = 5;
    err = I2C_wait_till_done();
    while (I2C3->MCS & 0x40);
    if (err) return err;
    return 0;
}

char I2C3_read_Multiple(int slave_address, char slave_memory_address, int count, char* data)
{
    char err;

    if (count <= 0)
        return -1;

    I2C3->MSA = slave_address << 1;
    I2C3->MDR = slave_memory_address;
    I2C3->MCS = 3;
    err = I2C_wait_till_done();
    if (err)
        return err;

    I2C3->MSA = (slave_address << 1) + 1;

    if (count == 1)
        I2C3->MCS = 7;
    else
        I2C3->MCS = 0xB;
    err = I2C_wait_till_done();
    if (err) return err;

    *data++ = I2C3->MDR;

    if (--count == 0)
    {
        while (I2C3->MCS & 0x40);
        return 0;       /* no err */
    }

    while (count > 1)
    {
        I2C3->MCS = 9;
        err = I2C_wait_till_done();
        if (err) return err;
        count--;
        *data++ = I2C3->MDR;
    }

    I2C3->MCS = 5;
    err = I2C_wait_till_done();
    *data = I2C3->MDR;
    while (I2C3->MCS & 0x40);

    return 0;
}
