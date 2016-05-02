#include "bitonic_sort.h"


__global__ void create_bitonic(int *input,  int stride, int length) {
    int tid = (blockIdx.z * gridDim.x * gridDim.y
                + blockIdx.y * gridDim.x
                + blockIdx.x) * blockDim.x + threadIdx.x; 
    int group = tid /stride;
    int order = tid % stride;
    bool even = group % 2 == 0? 1 : 0;
    
    for( int i = stride; i > 0; i = i /2) {
    
        int group1 = order / i;
        int order1 = order % i;
        int index = group * stride * 2 + group1 * i * 2 + order1;
        int index2 = index + i;
        if (index2 > length || index > length) return;
        bool less = input[index] < input[index2] ? 1 : 0;
        bool greater = input[index] > input[index2] ? 1 : 0;
        if ((even && greater)||(!even && less)) {
            int  tmp = input[index];
            input[index] = input[index2];
            input[index2] = tmp;
        } 
        
        __syncthreads();
    }
                
        
}


__global__ void bitonic_sort(int *input,  int stride, int length) {
    int tid = (blockIdx.z * gridDim.x * gridDim.y
                + blockIdx.y * gridDim.x
                + blockIdx.x) * blockDim.x + threadIdx.x;   
    int group = tid /stride;
    int order = tid % stride;
    
    for( int i = stride; i > 0; i = i /2) {
    
        int group1 = order / i;
        int order1 = order % i;
        int index = group * stride * 2 + group1 * i * 2 + order1;
        int index2 = index + i;
        if (index2 > length || index > length) return;
        if (input[index] < input[index2]) {
            int  tmp = input[index];
            input[index] = input[index2];
            input[index2] = tmp;        
        
        }
 
        __syncthreads();
    }
                        
        
}

__global__ void initial(int * input, int start, int m) {
    int tid = (blockIdx.z * gridDim.x * gridDim.y
                + blockIdx.y * gridDim.x
                + blockIdx.x) * blockDim.x + threadIdx.x;  
    input[start + tid] = m;
}
void bitonic_sort(Data *data) {
 

    int powerlength = pow(2, ceil(log2((double)(data->length))));
    int threads;
    Grid grid;

    int length = powerlength * sizeof(int);
    cal_grid(&grid, &threads, powerlength - data->length, 1);

    dim3 blocks(grid.blockx, grid.blocky, grid.blockz);
printf("length  %d,  , blocks %d, threads %d max %d\n", data->length, grid.blockx, threads, powerlength);
    clock_t begin, end;
    double time_spent;
        
   
    int *input;
    cudaMalloc((void**)&input, length);
    cudaMemcpy(input, data->intarray, data->length * sizeof(int), cudaMemcpyHostToDevice);
    int comp[powerlength - data->length];
    initial<<<blocks, threads>>>(input, data->length, INT_MAX);
    cudaMemcpy(comp, input + data->length, (powerlength -data->length) * sizeof(int), cudaMemcpyDeviceToHost);

for (int i = 0; i < powerlength -data->length; i++) printf("first com %d\n", comp[i]);

    cal_grid(&grid, &threads, powerlength, 2);

    begin = clock();
    int i = 1;
    for (; i < data->length/2; i *= 2) {
        create_bitonic<<<blocks, threads>>>(input, i, data->length);
    }
    create_bitonic<<<blocks, threads>>>(input, i, data->length);
    cudaMemcpy(data->intarray, input, data->length * sizeof(int), cudaMemcpyDeviceToHost);
    end = clock();
    time_spent = (double)(end - begin) / CLOCKS_PER_SEC;

    
    cudaMemcpy(comp, input + data->length, (powerlength -data->length) * sizeof(int), cudaMemcpyDeviceToHost);
for (int i = 0; i < powerlength -data->length; i++) printf("com %d\n", comp[i]);

    fprintf(stdout, "Parallel Bitonic sort time: %f\n", time_spent);
    cudaFree(input);

}
