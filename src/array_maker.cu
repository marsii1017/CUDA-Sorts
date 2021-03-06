#include "structs.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "array_maker.h"

const double PI = 3.14159265359;
const int NUM_BUCKETS = 10;

Data *generate_data (Data_info *specs)
{
        Data *data = (Data *)malloc(sizeof(*data));
        data->intarray = NULL;
        data->floatarray = NULL;
        long long max = specs->max;
        long long min = specs->min;
        data->length = specs->sample_size;

        if (specs->contents == INT) {
                data->intarray = (int *)malloc(specs->sample_size * sizeof(int));
                data->array_used = INT;
                if (specs->order == UNSORTED) {
                        if (specs->dist == UNIFORM) {
                                for (unsigned long long i = 0; i < specs->sample_size; i++) {
                                        data->intarray[i] = next_uniform(min, max);
                                }
                        } else if (specs->dist == GAUSSIAN) {
                                for (unsigned long long i = 0; i < specs->sample_size; i++) {
                                        data->intarray[i] = next_gaussian(min, max);
                                }
                        } else if (specs->dist == CONSTANT) {
                                int value = next_uniform(min, max);
                                for (unsigned long long i = 0; i < specs->sample_size; i++) {
                                        data->intarray[i] = value;
                                }
                        } else if (specs->dist == QUADRATIC) {
                                if (min < 0) {
                                        fprintf(stderr, "ERROR: minimum of a quadratic distribution cannot be negative.");
                                        exit(EXIT_FAILURE);
                                }
                                for (unsigned long long i = 0; i < specs->sample_size; i++) {
                                        data->intarray[i] = next_quadratic(min, max);
                                }
                        } else if (specs->dist == BUCKETS) {
                                for (unsigned long long i = 0; i < specs->sample_size; i++) {
                                        data->intarray[i] = next_bucket(min, max);
                                }
                        }
                } else if (specs->order == SORTED) {

                }

        } else if (specs->contents == FLOAT) {
            data->floatarray = (float *)malloc(specs->sample_size * sizeof(float));
            data->array_used = FLOAT;
            if (specs->dist == UNIFORM) {
                for (unsigned long long i = 0; i < specs->sample_size; i++) {
                    data->floatarray[i] = next_double();
                }
            }

        }

        return data;
}

double next_double ()
{
        return ((double) rand()) / ((double) (RAND_MAX));
}

int next_uniform (long long min, long long max)
{
        return rand() % (max - min) + min;
}

int next_gaussian (long long min, long long max)
{
        /* Box-Muller Transform */
        double r = sqrt(-2 * log(next_double()));
        double theta = 2 * PI * next_double();
        double x = r * cos(theta);
        double y = r * sin(theta);

        long long final;
        if (next_double() > 0.5) {
                /* value * SD + mean */
                final = (x * ((max - min) / 5)) + ((max + min) / 2);
        } else {
                final = (y * ((max - min) / 5)) + ((max + min) / 2);
        }

        if (final > max || final < min) return next_gaussian (min, max);
        return final;

}

int next_quadratic (long long min, long long max)
{
        int val = (rand() % (max - min) + min) - max;
        return min * val * val;
}

int next_bucket (long long min, long long max)
{
        int val = rand() % NUM_BUCKETS;
        val = val * (max - min) + min;
        return val;
}

void print_array (Data *data) {
        fprintf(stderr, "Printing array contents:\n");
        if (data->array_used == INT) {
                for (unsigned long long i = 0; i < data->length; i++) {
                        fprintf(stdout, "%d\n", data->intarray[i]);
                }
        } else if (data->array_used == FLOAT) {
                for (unsigned long long i = 0; i < data->length; i++) {
                        fprintf(stdout, "%lf\n", data->floatarray[i]);
                }
        }
}

void prettyprint_array (Data *data) {
        fprintf(stderr, "Printing array contents:\n");
        if (data->array_used == INT) {
                for (unsigned long long i = 0; i < data->length; i++) {

                        if (i + 1 == data->length) {
                                fprintf(stdout, "[%d]\n", data->intarray[i]);
                                break;
                        }

                        fprintf(stdout, "[%d], ", data->intarray[i]);
                }

        } else if (data->array_used == FLOAT) {
                for (unsigned long long i = 0; i < data->length; i++) {
                        if (i + 1 == data->length) {
                                fprintf(stdout, "[%lf]\n", data->floatarray[i]);
                                break;
                        }

                        fprintf(stdout, "[%lf], ", data->floatarray[i]);
                }
        }
}

