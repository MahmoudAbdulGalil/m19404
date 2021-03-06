/* ========================================================================
 * Copyright [2013][prashant iyengar] The Apache Software Foundation
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 * ========================================================================
 */

#define DATA_TYPE unsigned char
#define TILE_WIDTH 16
#define TILE_HEIGHT 16
#define KERNEL_RADIUS 1
#define TS 25
//#define MASK_WIDTH 3
//#define MASK_HEIGHT 3

#define KERNEL_RADIUS 8

#define      ROWS_BLOCKDIM_X 16
#define      ROWS_BLOCKDIM_Y 4
#define   COLUMNS_BLOCKDIM_X 16
#define   COLUMNS_BLOCKDIM_Y 8

#define    ROWS_RESULT_STEPS 4
#define      ROWS_HALO_STEPS 1
#define COLUMNS_RESULT_STEPS 4
#define   COLUMNS_HALO_STEPS 1

//1D separable row convolution
__kernel void conv_row(const __global DATA_TYPE * M,const __global DATA_TYPE *N,__global float * output,const int mode)
{
const int gx=get_global_id(0);
const int gy=get_global_id(1);
const int gz=get_global_id(2);
const int n=MASK_DIM/2;

const int loop=mode*HEIGHT+(1-mode)*WIDTH;
const int iter=mode*WIDTH+(1-mode)*HEIGHT;
const int scale=1;
if(gy <iter)
{

	for(int x=0;x<loop;x++)
	{

		float value=0;
		float value1=0;
		float value2=0;
 		int start_point=x-n;

		//performing the convolution  operation
		for(int j=0;j<MASK_DIM;j++)
		{
		
			//Reading the values for RGB channels 

		        value=value+ (((start_point+j)>=0 && (start_point + j) <loop)?M[(gy*WIDTHSTEP)+(start_point+j)*STEP+0]*N[j]:0);

			if(STEP==3)
 			{
			value1=value1+(((start_point+j)>=0 && (start_point + j) <loop) ?M[(gy*WIDTHSTEP)+(start_point+j)*STEP+1]*N[j]:0);
			value2=value2+(((start_point+j)>=0 && (start_point + j) <loop) ?M[(gy*WIDTHSTEP)+(start_point+j)*STEP+2]*N[j]:0);
			}
			//wrting the ifelse as test condition to avoid control divegence
		}
		//writing to the transposed locations
		output[(x*WIDTHSTEP)+(gy)*STEP+0]=(float)value;
		if(STEP==3)
		{
			output[(x*WIDTHSTEP)+(gy)*STEP+1]=value1;
			output[(x*WIDTHSTEP)+(gy)*STEP+2]=value2;
		}				


		//writing the values for RGB channels

	}


}





}



__kernel void conv_col(const __global float * M,const __global DATA_TYPE *N,__global DATA_TYPE * output,const int mode)
{
const int gx=get_global_id(0);
const int gy=get_global_id(1);
const int gz=get_global_id(2);
const int n=MASK_DIM/2;

const int loop=mode*HEIGHT+(1-mode)*WIDTH;
const int iter=mode*WIDTH+(1-mode)*HEIGHT;
const int scale=SCALE;
if(gy <iter)
{

	for(int x=0;x<loop;x++)
	{

		float value=0;
		float value1=0;
		float value2=0;
 		int start_point=x-n;

		//performing the convolution  operation
		for(int j=0;j<MASK_DIM;j++)
		{
		
			//Reading the values for RGB channels 

		        value=value+ (((start_point+j)>=0 && (start_point + j) <loop)?M[(gy*WIDTHSTEP)+(start_point+j)*STEP+0]*N[j]:0);

			if(STEP==3)
 			{
			value1=value1+(((start_point+j)>=0 && (start_point + j) <loop) ?M[(gy*WIDTHSTEP)+(start_point+j)*STEP+1]*N[j]:0);
			value2=value2+(((start_point+j)>=0 && (start_point + j) <loop) ?M[(gy*WIDTHSTEP)+(start_point+j)*STEP+2]*N[j]:0);
			}
			//wrting the ifelse as test condition to avoid control divegence
		}
		//writing to the transposed locations
		output[(x*WIDTHSTEP)+(gy)*STEP+0]=value/scale;//M[(gy*WIDTHSTEP)+(x)*STEP+0];//value;
//		output[(x*WIDTHSTEP)+STEP*(gy)]=value;
		if(STEP==3)
		{
			output[(x*WIDTHSTEP)+(gy)*STEP+1]=value1/scale;
			output[(x*WIDTHSTEP)+(gy)*STEP+2]=value2/scale;
		}				


		//writing the values for RGB channels

	}


}

//${NDKROOT}/platforms/android-9/arch-arm/usr/include
//${NDKROOT}/sources/cxx-stl/gnu-libstdc++/include
//${ProjDirPath}/../../sdk/native/jni/include

	



}


//naive 2d convolution
//M is input image,with no of rows and columns given by width and height
//N is the kernel with no of rows and columns given by mask_width and mask_height
//P is the output image which is the same size as input image
__kernel void conv2D_1(__global DATA_TYPE * M,__global DATA_TYPE *N,__global DATA_TYPE * output)
{
//getting the global and local thread id's
const int x=get_global_id(0);
const int y=get_global_id(1);
const int z=get_global_id(2);

const int width=WIDTH;
const int height=HEIGHT;
const int widthstep=WIDTHSTEP;
const int n=MASK_HEIGHT/2;

if(x<WIDTH && y <HEIGHT && z<STEP)
{
//performs computation for pixels in the valid range
int value=0; //local variable used  to store convolution sum
for(int i=0;i<MASK_HEIGHT;i++)
{
//loop over the rows of the pixel neighborhood
for(int j=0;j<MASK_WIDTH;j++)
{
//loop over the columns of the pixels neighborhood


    if((y+i-n>=0) && (x+j-n>=0) && ((y+i-n)< HEIGHT) && ((x+j-n) <WIDTH))
    {
        //condition defines pixels lying within the image borders
        value=value+M[(y+i-n)*widthstep+STEP*(x+j-n)+z];//*N[(i)*(MASK_WIDTH)+j];
        //reading the data from global input memory and computing the convolution sum over the neighborhood

   }
}
}
//copying the data to global output memory
output[y*widthstep+STEP*x+z]=value/(MASK_WIDTH*MASK_HEIGHT);;

}
}






//2d convolution using 2D local memory loads
__kernel void conv2D_2( __constant DATA_TYPE * M,__constant DATA_TYPE *N, __global DATA_TYPE * output)
{

const int x=get_global_id(0);
const int y=get_global_id(1);
const int z=get_global_id(2);
const int lx=get_local_id(0);
const int ly=get_local_id(1);
const int bx=get_group_id(0);
const int by=get_group_id(1);
const int ls=get_local_size(0);

const int widthstep=WIDTHSTEP;
const int width=WIDTH;
const int height=HEIGHT;
const int mask_height=MASK_DIM;
const int mask_width=MASK_DIM;

__local DATA_TYPE Nl[TS][TS];

const signed int n=MASK_WIDTH/2;

const signed int left=((bx)*ls-n+lx);
const signed int top=((by)*ls-n+ly);
const signed int right=((bx)*ls+n+lx);
const signed int bottom=((by)*ls+n+ly);



const signed int left_index=min(max((x-n),0),width);
const signed int top_index=min(max((y-n),0),height);

const signed int idx=top_index*widthstep+STEP*(left_index)+z;
const signed int cidx=(y)*widthstep+STEP*(x)+z;

const signed int idx1=top_index*widthstep+STEP*(left_index)+1;
const signed int cidx1=(y)*widthstep+STEP*(x)+1;

const signed int idx2=top_index*widthstep+STEP*(left_index)+2;
const signed int cidx2=(y)*widthstep+STEP*(x)+2;

const signed int idx0=top_index*widthstep+STEP*(left_index)+0;
const signed int cidx0=(y)*widthstep+STEP*(x)+0;


int value=0;

if(x<width && y <height && z<3)
{

//left border pixels
if(lx < n && ly >=n )	
{

   if(left<0)
   Nl[lx][ly+n]=0;
   else
   Nl[lx][ly+n]=M[idx];

}
//bottom border pixels
if(lx<ls-n && ly >=ls-n)  
{
    if(bottom>=height)
    Nl[lx+n][ly+n+n]=0;
    else
    Nl[lx+n][ly+n+n]=M[idx];

}

//top border pixels
if(lx>=n && ly <n )
{
    if(top<0)
    Nl[lx+n][ly]=0;
    else
    Nl[lx+n][ly]=M[idx];
}

//right border pixels
if(lx >=ls-n && ly <ls-n )	//0,15
{
   if(right>=width)
   Nl[lx+n+n][ly+n]=0;
   else
   Nl[lx+n+n][ly+n]=M[idx];


}

///bottom left
if(lx <n && ly >=ls-n )
{
        if(left<0)
        Nl[lx][ly+n]=0;
        else
        Nl[lx][ly+n]=M[idx];

        if(bottom>=height)
        Nl[lx+n][ly+n+n]=0;
        else
        Nl[lx+n][ly+n+n]=M[idx];

        if(left<0 || bottom>=height)
        Nl[lx][ly+n+n]=0;
        else
        Nl[lx][ly+n+n]=M[idx];
}


//top left
if(lx < n && ly <n )
{

	
        if(left<0)
        Nl[lx][ly+n]=0;
        else
        Nl[lx][ly+n]=M[idx];

        if(top<0)
        Nl[lx+n][ly]=0;
        else
        Nl[lx+n][ly]=M[idx];

        if(left<0 || top <0)
        Nl[lx][ly]=0;
        else
        Nl[lx][ly]=M[idx];

}

//top right
if(lx >= ls-n && ly <n )
{

        if(right>=width)
        Nl[lx+n+n][ly+n]=0;
        else
        Nl[lx+n+n][ly+n]=M[idx];

        if(top<0)
        Nl[lx+n][ly]=0;
        else
        Nl[lx+n][ly]=M[idx];

        if(right>=width || top <0)
        Nl[lx+n+n][ly]=0;
        else
        Nl[lx+n+n][ly]=M[idx];

}


///bottom right
if(lx >= ls-n && ly >=ls-n )
{
        if(right>=width)
        Nl[lx+n+n][ly+n]=0;
        else
        Nl[lx+n+n][ly+n]=M[idx];

        if(bottom>=height)
        Nl[lx+n][ly+n+n]=0;
        else
        Nl[lx+n][ly+n+n]=M[idx];

        if(right>=width||bottom>=height)
        Nl[lx+n+n][ly+n+n]=0;
        else
        Nl[lx+n+n][ly+n+n]=M[idx];
}



Nl[n+lx][n+ly]=M[cidx];
}

barrier(CLK_LOCAL_MEM_FENCE);

if(x<width && y <height &&z<3)
{

#ifdef UNROLL1
#pragma unroll 10
for(int i=0;i<MASK_HEIGHT;i++)
{
for(int j=0;j<MASK_WIDTH;j++)
{
	value=value+Nl[j+lx][i+ly];//*N[i*MASK_WIDTH+j];

}
}
#else
//
	value=value+Nl[0+lx][0+ly]*N[0*MASK_WIDTH+0];
	value=value+Nl[1+lx][0+ly]*N[0*MASK_WIDTH+1];
	value=value+Nl[2+lx][0+ly]*N[0*MASK_WIDTH+2];
	value=value+Nl[0+lx][1+ly]*N[1*MASK_WIDTH+0];
	value=value+Nl[1+lx][1+ly]*N[1*MASK_WIDTH+1];
	value=value+Nl[2+lx][1+ly]*N[1*MASK_WIDTH+2];
	value=value+Nl[0+lx][2+ly]*N[2*MASK_WIDTH+0];
	value=value+Nl[1+lx][2+ly]*N[2*MASK_WIDTH+1];
	value=value+Nl[2+lx][2+ly]*N[2*MASK_WIDTH+2];
#endif



output[y*widthstep+STEP*x+z]=value/(MASK_WIDTH*MASK_HEIGHT);

}
}






















