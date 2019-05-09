use Random;
use Math;
use Time;

var randomStream = new RandomStream(real, parSafe=true);

proc samplePi(samples_num: uint, i : int): real {
    var sum: real = 0.0;
    var arrayX: [1..samples_num] real;
    var arrayY: [1..samples_num] real;
    randomStream.fillRandom(arrayX);
    randomStream.fillRandom(arrayY);
    for i in 1..samples_num{
        if (arrayX[i]**2 + arrayY[i]**2 < 1) {
            sum += 1.0;
        }
    }
    var res = 4.0*(sum/samples_num);
    return res;
}

proc calculatePI(N: uint): void{
    var form_array : [0..(N-1)] real;

    forall (elem, i) in zip(form_array, 0..) {
        elem = samplePi(1000000, i);
    }
    var value = + reduce form_array;
    value /= N;
}

proc calculatePI_co(N: uint): void{
    var form_array : [0..(N-1)] real;

    coforall (elem, i) in zip(form_array, 0..) {
        elem = samplePi(1000000, i);
    }
    var value = + reduce form_array;
    value /= N;
}

proc eratosthenesSieve(N: uint){
    var a: [0..(N-1)] bool; // initialises with falses at the beginning
    var upper: uint = sqrt(N):uint;
    coforall i in 2..upper do{
        if a[i] == false {
            var j:uint = i**2;
             while (j < N) {
                a[j] = true;
                j += i;
            }
        }
    }
}

proc eratosthenesSieveLin(N: uint){
    var a: [0..(N-1)] bool; // initialises with falses at the beginning
    var upper: uint = sqrt(N):uint;
    for i in 2..upper{
        if a[i] == false {
            var j:uint = i**2;
            while (j < N) {
                a[j] = true;
                j += i;
            }
        }
    }
}


proc pi2(n:uint){
    // number of random points to try
    var seed = 589494289;// seed for random number 
    // writeln("Number of points    = ", n); 
    // writeln("Random number seed  = ", seed); 
    // var rs = new RandomStream(real, seed, parSafe=true);
    var count = 0; 
    for i in 1..n do
        if(randomStream.getNext()**2 + randomStream.getNext()**2) <= 1.0 then 
        count += 1; 
    // writeln("Approximation of pi = ", count*4.0 / n); 
    // delete rs; 
}

config const N:uint = 10;
config const it: uint = 9;
config const name: string = "test_file_sieve";
var myFileser = open("serial_"+ name+".txt", iomode.cw);
var myFilepar = open("par_"+ name+".txt", iomode.cw);
var myFileco = open("co_"+ name+".txt", iomode.cw);

var myWritingChannelser = myFileser.writer();
var myWritingChannelco = myFileco.writer();
var myWritingChannelpar = myFilepar.writer();

for i in 1..it do{
    var tn:uint = 10**i;
    writeln("Current it:", i, " val is: ", tn);
    var startTime = getCurrentTime();
    calculatePI(i);
    // eratosthenesSieve(tn);
    var stopTime = getCurrentTime();
    myWritingChannelpar.write(i, " ", stopTime-startTime, "\n");

    startTime = getCurrentTime();
    calculatePI_co(i);
    // eratosthenesSieve(tn);
    stopTime = getCurrentTime();
    myWritingChannelco.write(i, " ", stopTime-startTime, "\n");
    
    
    startTime = getCurrentTime();
    // eratosthenesSieveLin(tn);
    pi2(N*i);
    stopTime = getCurrentTime();
    myWritingChannelser.write(i, " ", stopTime-startTime, "\n");
}


myWritingChannelpar.close();
myWritingChannelser.close();
myWritingChannelco.close();

myFilepar.close();
myFileser.close();
myFileco.close();
