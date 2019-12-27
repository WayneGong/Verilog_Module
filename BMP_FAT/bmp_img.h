#ifndef _BMP_IMG_H
#define _BMP_IMG_H
#include "xsdps.h"
#include "ff.h"
#endif
typedef unsigned short int WORD;
typedef unsigned int DWORD;
typedef int LONGG;
typedef unsigned char BYTE;

/*********** *********** *********** *********** *********** *********** ***********
* definition :struct
* Description :位图文件头
*********** *********** *********** *********** *********** *********** ***********/
#pragma pack(1)/////////////////将结构体中成员按n字节对齐
typedef struct tagBITMAPFILEHEADER
{
    WORD bfType;////////////////文件类型，必须为BM
    DWORD bfSize;///////////////指定文件大小，以字节为单位（3-6字节，低位在前）
    WORD bfReserved1;///////////文件保留字，必须为0
    WORD bfReserved2;///////////文件保留字，必须为0
    DWORD bfOffBits;////////////从文件头到实际位图数据的偏移字节数（11-14字节，低位在前）
}BITMAPFILEHEADER;
/*********** *********** *********** *********** *********** *********** ***********
* definition :struct
* Description :位图信息头
*********** *********** *********** *********** *********** *********** ***********/
typedef struct tagBITMAPINFOHEADER
{
	DWORD biSize;///////////////本结构所占用字节数，为40。注意：实际操作中则有44，这是字节补齐的原因
	LONGG biWidth;///////////////位图的宽度，以像素为单位
	LONGG biHeight;//////////////位图的高度，以像素为单位
	WORD biPlanes;//////////////目标设备的级别，必须为1
	WORD biBitCount;////////////每个像素所需的位数，1（双色），4(16色），8(256色）16(高彩色)，24（真彩色）或32之一
	DWORD biCompression;////////位图压缩类型，0（不压缩），1(BI_RLE8压缩类型）或2(BI_RLE4压缩类型）之一
	DWORD biSizeImage;//////////位图的大小(其中包含了为了补齐行数是4的倍数而添加的空字节)，以字节为单位
	LONGG biXPelsPerMeter;///////位图水平分辨率，每米像素数
	LONGG biYPelsPerMeter;///////位图垂直分辨率，每米像素数
	DWORD biClrUsed;////////////位图实际使用的颜色表中的颜色数，若该值为0,则使用颜色数为2的biBitCount次方
	DWORD biClrImportant;///////位图显示过程中重要的颜色数，若该值为0,则所有的颜色都重要
}BITMAPINFOHEADER;
#pragma pack()//////////////////取消自定义字节方式
/*********** *********** *********** *********** *********** *********** ***********
* definition :struct
* Description :调色板
*********** *********** *********** *********** *********** *********** ***********/
typedef struct tagRGBQUAD
{
	BYTE rgbBlue;///////////////蓝色的亮度（0-255)
	BYTE rgbGreen;//////////////绿色的亮度（0-255)
	BYTE rgbRed;////////////////红色的亮度（0-255)
	BYTE rgbReserved;///////////保留，必须为0
}RGBQUAD;

/*********** *********** *********** *********** *********** *********** ***********
* Function Name :printInfo
* Description :输出文件信息
*********** *********** *********** *********** *********** *********** ***********/
void printInfo(BITMAPFILEHEADER fileHeader,BITMAPINFOHEADER infoHeader);
/*********** *********** *********** *********** *********** *********** ***********
* Function Name :printInfo
* Description :输出画板信息
*********** *********** *********** *********** *********** *********** ***********/
void printPalette(RGBQUAD *rgbPalette,int sizeOfPalette);
//int ReadBmp(BITMAPFILEHEADER fileHeader,BITMAPINFOHEADER infoHeader,RGBQUAD *rgbPalette/*给它去别名一起变化*/,void *img[5000],char *FileName);
int SaveBmp(BITMAPFILEHEADER fileHeader,BITMAPINFOHEADER infoHeader,RGBQUAD *rgbPalette,u8 *img,char *FileName);
