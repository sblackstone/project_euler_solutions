#include <stdio.h>
#include <stdlib.h>


long mod_pow(long base, long power, long mod) {
	long result = 1;
	while (power > 0) {
    if (power & 1 == 1) {
			result = (result * base) % mod;	
    }
		base = (base * base) % mod;
		power >>= 1;
		
	}
	return(result);
}

int fast_prime(long n) {
	if (n == 2) return true;
	if (n  < 2) return false;
	if (n % 2 == 0) return false;
	long d = n - 1;
	while (d % 2 == 0) {
		d /= 2;
	}
	int abase[] = {2,3,5,7,11};
	for (int i = 0; i < 6; i++) {
		int a = abase[i];
		if (a==n) { return(true); }
		long t = d;
		long y = mod_pow(a,d,n);
    while (t != (n-1) && y != 1 && y != (n-1)) {
			y = (y*y) % n;
			t *= 2;
    }
    if (y != (n-1) && (t % 2 == 0)) {
			return(false);
    }
	}
	return(true);
}


int check(int n) {
  int n2 = n * n;
  int i;
  for (i=1; i <= 27; i+= 2) {
    if (fast_prime(n2+i) == 1 && valid[i] == 0 || 
        fast_prime(n2+i) == 0 && valid[i] == 1
       ) {
      return(0);
    }
  }
  return(1);
}

int main() {
  valid[1] = 1;
  valid[3] = 1;
  valid[7] = 1;
  valid[9] = 1;
  valid[13] = 1;
  valid[27] = 1;
  int j;
  for (j=2; j < 1000000; j+=2) {
    if (check(j) == 1) {
      printf("%i\n",j);
    }
  }
}



