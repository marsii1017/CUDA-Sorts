#include "quicksort.h"
#include <stdio.h>

/*
 *      To sort all array, call A, 1, length[A]
 */
void quicksort(Data *data)
{



        if (data->array_used == INT) {
	        clock_t begin, end;
	        double time_spent;
	        begin = clock();

                quicksort_int(data->intarray, 0, data->length);
	        end = clock();
	        time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	        fprintf(stdout, "Serial Quicksort time: %f\n", time_spent);
        } else if (data->array_used == FLOAT) {
                quicksort_float(data->floatarray, 0, data->length);
        }




}


void quicksort_int(int *a, int p, int r)
{
	if(p < r) {
		int q = partition_int(a, p, r);
                quicksort_int(a, p, q-1);
	        quicksort_int(a, q+1, r);
	}
}

int partition_int(int* a, int p, int r)
{
        int x = a[r];
	int i = p-1;
	for(int j=p; j <r; j++) {
	        if(a[j] <= x) {
                        i++;
	                int temp= a[i];
			a[i]= a[j];
			a[j]= temp;
	        }
	}
	int temp= a[i+1];
	a[i+1] = a[r];
	a[r]= temp;
	return i+1;
}


void quicksort_float(float *a, int p, int r)
{
	if(p < r) {
		int q = partition_float(a, p, r);
                quicksort_float(a, p, q-1);
	        quicksort_float(a, q+1, r);
	}
}

int partition_float(float* a, int p, int r)
{
        int x = a[r];
	int i = p-1;
	for(int j=p; j <r; j++) {
	        if(a[j] <= x) {
                        i++;
	                float temp= a[i];
			a[i]= a[j];
			a[j]= temp;
	        }
	}
	int temp= a[i+1];
	a[i+1] = a[r];
	a[r]= temp;
	return i+1;
}
