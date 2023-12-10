module Series1


/*
 * Documentation: https://www.rascal-mpl.org/docs/GettingStarted/
 */

/*
 * Hello world
 *
 * - Import IO, write a function that prints out Hello World!
 * - open the console (click "Import in new Rascal Terminal")
 * - import this module and invoke helloWorld.
 */

import IO;

void helloWorld() {
  println("Hello World!");
}


/*
 * FizzBuzz (https://en.wikipedia.org/wiki/Fizz_buzz)
 * - implement imperatively
 * - implement as list-returning function
 */

void fizzBuzz() {
  for (int n <- [1 .. 31])
    if (!(n % 3 == 0 || n % 5 == 0)) {
      println(n);
    } else {
      if (n % 3 == 0)
        print("fizz");
      if (n % 5 == 0)
        print("buzz");
      println();
    }
}

list[str] fizzBuzzList() {
  str process(int n) {
    if (n % 15 == 0)
      return "fizzbuzz";
    if (n % 3 == 0)
      return "fizz";
    if (n % 5 == 0)
      return "buzz";
    return "<n>";
  }

  return [process(n) | int n <- [1 .. 31]];
}


/*
 * Factorial
 * - first using ordinary recursion
 * - then using pattern-based dispatch
 *  (complete the definition with a default case)
 */

default int factorial(int n) {
  if (n == 1)
    return 1;
  return n * factorial(n - 1);
}

int fact(0) = 1;
int fact(1) = 1;

default int fact(int n) = n * fact(n - 1);


/*
 * Comprehensions
 * - use println to see the result
 */

void comprehensions() {

  // construct a list of squares of integer from 0 to 9 (use range [0..10])
  println([n*n | n <- [0..10]]);

  // same, but construct a set
  println({n*n | n <- [0..10]});

  // same, but construct a map
  println((n: n*n | n <- [0..10]));

  // construct a list of factorials from 0 to 9
  println([fact(n) | n <- [0..10]]);

  // same, but now only for even numbers
  println([fact(n) | n <- [0,2..10]]);
}


/*
 * Pattern matching
 * - fill in the blanks with pattern match expressions (using :=)
 */

void patternMatching() {
  str hello = "Hello World!";

  // print all splits of list
  list[int] aList = [1,2,3,4,5];
  for ([*L1, *L2] := aList) {
    println("<L1>, <L2>");
  }

  // print all partitions of a set
  set[int] aSet = {1,2,3,4,5};
  for ({*S1, *S2} := aSet) {
    println("<S1>, <S2>");
  }
}


/*
 * Trees
 * - complete the data type ColoredTree with
 *   constructors for binary red and black branches
 * - use the exampleTree() to test in the console
 */

data ColoredTree
  = leaf(int n)
  | red(ColoredTree left, ColoredTree right)
  | black(ColoredTree left, ColoredTree right);

ColoredTree exampleTree()
  = red(black(leaf(1), red(leaf(2), leaf(3))), black(leaf(4), leaf(5)));


// write a recursive function summing the leaves
// (use switch or pattern-based dispatch)

int sumLeaves(leaf(int n)) = n;
default int sumLeaves(red(ColoredTree l, ColoredTree r)) = sumLeaves(l) + sumLeaves(r);
default int sumLeaves(black(ColoredTree l, ColoredTree r)) = sumLeaves(l) + sumLeaves(r);

// same, but now with visit
int sumLeavesWithVisit(ColoredTree t) {
  int n = 0;
  visit(t) {
    case leaf(int val): n += val;
  }
  return n;
}

// same, but now with a for loop and deep match
int sumLeavesWithFor(ColoredTree t) {
  int n = 0;
  for (/leaf(int val) := t)
    n += val;
  return n;
}

// same, but now with a reducer and deep match
// Reducer = ( <initial value> | <some expression with `it` | <generators> )
int sumLeavesWithReducer(ColoredTree t) = (0 | it + val | /leaf(int val) := t);


// add 1 to all leaves; use visit + =>
ColoredTree inc1(ColoredTree t) {
  return visit(t) {
    case leaf(int val) => leaf(val + 1)
  }
}

// write a test for inc1, run from console using :test
test bool testInc1()
  = inc1(exampleTree())
    == red(black(leaf(2), red(leaf(3), leaf(4))), black(leaf(5), leaf(6)));  

// define a property for inc1, i.e. a boolean
// function that checks if one tree is inc1 of the other
// (without using inc1).
// Use switch on the tupling of t1 and t2 (`<t1, t2>`)
// or pattern based dispatch.
// Hint! The tree also needs to have the same shape!
bool isInc1(ColoredTree t1, ColoredTree t2) {
  switch (<t1, t2>) {
    case <leaf(int v1), leaf(int v2)>:
      return v2 == v1 + 1;
    case <red(ColoredTree l1, ColoredTree r1), red(ColoredTree l2, ColoredTree r2)>:
      return isInc1(l1, l2) && isInc1(r1, r2);
    case <black(ColoredTree l1, ColoredTree r1), black(ColoredTree l2, ColoredTree r2)>:
      return isInc1(l1, l2) && isInc1(r1, r2);
    default: return false;
  }
}

bool isInc1_(leaf(int v1), leaf(int v2)) = v2 == v1 + 1;
bool isInc1_(red(ColoredTree l1, ColoredTree r1),
  red(ColoredTree l2, ColoredTree r2)) = isInc1_(l1, l2) && isInc1_(r1, r2);
bool isInc1_(black(ColoredTree l1, ColoredTree r1),
  black(ColoredTree l2, ColoredTree r2)) = isInc1_(l1, l2) && isInc1_(r1, r2);
default bool isInc1_() = false;

// write a randomized test for inc1 using the property
// again, execute using :test
test bool testInc1Randomized(ColoredTree t1) = isInc1_(t1, inc1(t1));







