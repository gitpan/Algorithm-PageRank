#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <math.h>

typedef double vector;
typedef double* matrix;

//////////////////////////////////////////////////////////////////////

void _kill_prv(p)
 I32 p;
{
  vector *ptr;
  ptr = INT2PTR(vector*, p);
  Safefree(ptr);
}


I32 _create_prv(size)
 I32 size;
{
  vector *v;
  Newz(0, v, size, double);
  return PTR2UV(v);
}


I32 _create_matrix(size)
 I32 size;
{
  I32 i;
  matrix *m;
  Newz(0, m, size, double*);
  for( i=size-1 ; i >= 0; i--)
    Newz(0, m[i], size, double);
  return PTR2UV(m);
}


void _kill_matrix(m, size)
 I32 m;
 I32 size;
{
  I32 i;
  matrix *ptr;
  ptr = INT2PTR(matrix*, m);
  for( i=size-1; i>=0 ; i--){
    Safefree(ptr[i]);
  }
  Safefree(ptr);
}

void _load_outdegree(outdeg, length, dbprefix)
 I32 *outdeg;
 I32 length;
 char* dbprefix;
{
 char filename[512];
 PerlIO *odio;

 sprintf(filename, "%s.outdeg", dbprefix);
 odio = PerlIO_open(filename, "r");
 PerlIO_read(odio, outdeg, sizeof(I32)*length);
 PerlIO_close(odio);
}



I32 _multiply(vsize, m, v, t, dbprefix)
 I32 vsize;
 I32 m;
 I32 v;
 I32 t;
 char *dbprefix;
{
  I32 row, j, k, pos;
  vector *tmpvptr, *vptr, *tptr;
  PerlIO *idxio, *invio, *prio;
  I32 *outdeg, *vec;
  I32 veclen;
  bool is_identical;
  char filename[512];
  double norm;
  double tmp[] = { 0.025, 0.1, 0.325, 0.2, 0.35 };
  vptr = INT2PTR(vector*, v);

  // temp pagerank vector
  Newz(0, tmpvptr, vsize, double);

  // open the matrix database
  sprintf(filename, "%s.idx", dbprefix);
  idxio = PerlIO_open(filename, "r");
  sprintf(filename, "%s.inv", dbprefix);
  invio = PerlIO_open(filename, "r");

  // load each vertex's out degree 
  Newz(0, outdeg, vsize, I32);
  _load_outdegree(outdeg, vsize, dbprefix);


  for(j=0; j<vsize; j++){
   vptr[j] = (double)(1/(double)vsize);
   vptr[j] = tmp[j];
  }

  // has t iterations
  for(j = t-1; j>=0; j--){

   // the row number
   for(row = vsize - 1 ; row>=0 ; row--){
    tmpvptr[row] = 0;

    PerlIO_rewind(idxio);
    PerlIO_rewind(invio);
    PerlIO_seek(idxio, (1 + row + row)*sizeof(I32), SEEK_SET);
    PerlIO_read(idxio, &pos, sizeof(I32));
    PerlIO_read(idxio, &veclen, sizeof(I32));
    Newz(0, vec, veclen, I32);
    PerlIO_seek(invio, pos*sizeof(I32), SEEK_SET);
    PerlIO_read(invio, vec, veclen * sizeof(I32));


    // inner product
    for(k = veclen - 1 ; k>=0 ; k--)
      tmpvptr[row] +=  0.9 * (double)(1/(double)outdeg[vec[k]]) * vptr[vec[k]];

    // dampening effect
    tmpvptr[row] += 0.1 * (1/(double)vsize);


    Safefree(vec);
   }

   if(j > 5 && j % 5 == 1){
    is_identical = TRUE;
    for(k = vsize - 1; k>=0 ; k--){
      if( tmpvptr[k] != vptr[k] )
        is_identical = FALSE;
    }
    if(is_identical)
      break;
   }

   tptr = vptr;
   vptr = tmpvptr;
   tmpvptr = tptr;
  }

  sprintf(filename, "%s.pr", dbprefix);
  prio = PerlIO_open(filename, "w");
  PerlIO_write(prio, vptr, vsize*sizeof(double));
  PerlIO_close(prio);


  PerlIO_close(idxio);
  PerlIO_close(invio);

  Safefree(tmpvptr);
  Safefree(outdeg);
  Safefree(vec);
}


double
_getscalar(dbprefix, idx)
 char* dbprefix;
 I32 idx;
{

  char* filename;
  PerlIO *prio;
  double buf;

  filename = form("%s.pr", dbprefix);
  prio = PerlIO_open(filename, "r");
  Safefree(filename);

  PerlIO_seek(prio, idx * sizeof(double), SEEK_SET);
  PerlIO_read(prio, &buf, sizeof(double));
  return buf;
} 



//////////////////////////////////////////////////////////////////////
MODULE = Algorithm::PageRank		PACKAGE = Algorithm::PageRank		

I32
_create_prv(size)
 I32 size

void
_kill_prv(p)
 I32 p

double
_multiply(vsize, m, v, t, dbprefix)
 I32 vsize
 I32 m
 I32 v
 I32 t
 char* dbprefix


I32
_create_matrix(size)
 I32 size


void
_kill_matrix(m, size)
 I32 m
 I32 size

double
_getscalar(dbprefix, idx)
 char* dbprefix
 I32 idx

