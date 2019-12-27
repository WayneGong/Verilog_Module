#include "bmp_img.h"
/*********** *********** *********** *********** *********** *********** ***********
* Function Name :printInfo
* Description :输出文件信息
*********** *********** *********** *********** *********** *********** ***********/
/*********** *********** *********** *********** *********** *********** ***********
* Function Name :printInfo
* Description :输出画板信息
*********** *********** *********** *********** *********** *********** ***********/
/************************** Variable Definitions *****************************/


/*int ReadBmp(BITMAPFILEHEADER fileHeader,BITMAPINFOHEADER infoHeader,RGBQUAD *rgbPalette,void *img[5000],char *FileName)
{
	FILE *fpIn=fopen(FileName,"rb");
	int i=0,sizeOfHang=0,sizeOfPalette=0;

	if(fpIn==NULL)
		return false;

	fread(fileHeader,sizeof(BITMAPFILEHEADER),1,fpIn);
	fread(infoHeader,sizeof(BITMAPINFOHEADER),1,fpIn);

	if(infoHeader.biBitCount<16)
	{
		sizeOfPalette=int( pow(2,infoHeader.biBitCount) );
		rgbPalette=new RGBQUAD[sizeOfPalette];

		fread(rgbPalette,sizeof(RGBQUAD),sizeOfPalette,fpIn);
	}


	if( (infoHeader.biBitCount * infoHeader.biWidth)%32==0)
		sizeOfHang=(infoHeader.biBitCount * infoHeader.biWidth)/8;
	else
		sizeOfHang=((infoHeader.biBitCount * infoHeader.biWidth)/32+1)*4;

	for(i=0;i<infoHeader.biHeight;i++)
	{
		img[i]=(void *) new BYTE[sizeOfHang];
		fread(img[i],sizeOfHang,1,fpIn);
	}

	fclose(fpIn);
	return 0;
}*/


int SaveBmp(BITMAPFILEHEADER fileHeader,BITMAPINFOHEADER infoHeader,RGBQUAD *rgbPalette,u8 *img,char *FileName)
{
	FIL fil;		/* File object */
	FATFS fatfs;
	//char FileName[32] = "cam4.bmp";
	TCHAR *Path = "0:/";
	char *SD_File;
	FRESULT Res;
	UINT NumBytesWritten;
	char * RecData;
	RecData=0x04000000;
	Res = f_mount(&fatfs, Path, 0);
	if (Res != FR_OK) {
		return XST_FAILURE;
	}
	SD_File = (char *)FileName;
	Res = f_open(&fil, SD_File, FA_CREATE_ALWAYS | FA_WRITE | FA_READ);
	if (Res) {
		return XST_FAILURE;
	}
	Res = f_lseek(&fil, 0);
	if (Res) {
		return XST_FAILURE;
	}
	//int i=0;
	Res = f_write(&fil, &fileHeader,sizeof(BITMAPFILEHEADER),&NumBytesWritten);
	if (Res) {
		return XST_FAILURE;
	}
	Res = f_write(&fil, &infoHeader,sizeof(BITMAPINFOHEADER),&NumBytesWritten);
	if (Res) {
		return XST_FAILURE;
	}
	Res=f_write(&fil, img,1920*1080*3+256,&NumBytesWritten);
	if (Res) {
		return XST_FAILURE;
	}
//	Res = f_lseek(&fil, 0);
//	if (Res) {
//		return XST_FAILURE;
//	}
//	Res=f_read(&fil, RecData,1920*1080*3+256,&NumBytesWritten);
//	if (Res) {
//		return XST_FAILURE;
//	}
	Res = f_sync(&fil);
	if (Res) {
		return XST_FAILURE;
	}
	Res = f_close(&fil);
	if (Res) {
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}
