import UIKit

/*
//  Higher Order Functions
//
//  Suggested Reading:
//  http://www.objc.io/books/
//    (Functional Programming in Swift, by Chris Eidhof, Florian Kugler, and Wouter Swierstra)
/===================================*/



/*------------------------------------/
//  Naive computations
/------------------------------------*/
func plusOne(xs: [Int]) -> [Int] {
  var result = [Int]()
  for x in xs {
    result.append(x + 1)
  }
  return result
}

let v = [1, 2, 303, 304]
plusOne(v)


// Another function that computes `Int`s
func byTwo(xs: [Int]) -> [Int] {
  var result = [Int]()
  for x in xs {
    result.append(x * 2)
  }
  return result
}

byTwo(v)


// Generalize (but for `Int`s)
func computeInts(xs: [Int], f: Int -> Int) -> [Int] {
  var result = [Int]()
  for x in xs {
    result.append(f(x))
  }
  return result
}

computeInts(v, { x in
  return x % 2
})

// w/ Trailing closure
computeInts(v) { x in
  x * 3
}

// w/ Implicit parameter names
var r = computeInts(v) { $0 * 3 }
r

// w/ Named closure
let triple = { x in x * 3 }
computeInts(v, triple)

// Create a named function
func tripleInts(xs: [Int]) -> [Int] {
  return computeInts(xs) { $0 * 3 }
}
tripleInts(v)


/*------------------------------------/
//  What about a different type?
//    This approach doesn't scale.
/------------------------------------*/
// What about creating "squares?"
// The `pow` function only takes `Double`s.
func computeDoubles(xs: [Int], f: Int -> Double) -> [Double] {
  var result = [Double]()
  for x in xs {
    result.append(f(x))
  }
  return result
}

func squareInts(xs: [Int]) -> [Double] {
  return computeDoubles(xs) { pow(Double($0), 2) }
}

squareInts(v)


/*------------------------------------/
//  Is there a general solution?
//    A "generic" solution...
/------------------------------------*/
func computeArray<U>(xs: [Int], f: Int -> U) -> [U] {
  var result = [U]()
  for x in xs {
    result.append(f(x))
  }
  return result
}

// Reimplement this
func genericSquareInts(xs: [Int]) -> [Double] {
  return computeArray(xs) { pow(Double($0), 2) }
}
genericSquareInts(v)

// But, can reuse it for another type (Bool)
func genericEvens(xs: [Int]) -> [Bool] {
  return computeArray(xs) { $0 % 2 == 0 }
}
v
genericEvens(v)


/*------------------------------------------------/
//  Is there an *even more* general solution?
//    One that doesn't require `Int`s as input?
//
//  Or: A generic `map` function...
/------------------------------------------------*/
func map<T,U>(xs: [T], f: T -> U) -> [U] {
  var result = [U]()
  for x in xs {
    result.append(f(x))
  }
  return result
}

// use map directly
let r1000 = map(v) { $0 * 1000 }
r1000

// reuse map for [Int] -> [Int]
func tripleInts2(xs: [Int]) -> [Int] {
  return map(xs) { $0 * 3 }
}
tripleInts(v)

// reuse map for [Int] -> [Bool]
func evenInts(xs: [Int]) -> [Bool] {
  return map(xs) { $0 % 2 == 0 }
}
evenInts(v)

// reuse map for [Double] -> [Double]
func squares(xs: [Double]) -> [Double] {
  return map(xs) { pow($0, 2) }
}
let dv = [1.0, 2.2, 3.14, 4.0]
squares(dv)


/*------------------------------------/
//  Map already exists...
/------------------------------------*/
v
let doublev = v.map { $0 * 2 }
doublev

dv
let dvCubes = dv.map { pow($0, 3) }
dvCubes


/*------------------------------------/
//  Filter
/------------------------------------*/
// Say you want just the evens
func justEvens(xs: [Int]) -> [Int] {
  var result = [Int]()
  for x in xs {
    if x % 2 == 0 {
      result.append(x)
    }
  }
  return result
}
v
justEvens(v)


// This is a general "filter" operation
func filter<T>(xs: [T], check: T -> Bool) -> [T] {
  var result = [T]()
  for x in xs {
    if check(x) {
      result.append(x)
    }
  }
  return result
}
var evenvs = filter(v, { (x: Int) -> Bool in
  x % 2 == 0
})
evenvs

// w/ Trailing closure
evenvs = filter(v) { x -> Bool in
  x % 2 == 0
}
evenvs

// w/ Implicit parameter names
evenvs = filter(v) { $0 % 2 == 0 }
evenvs


// Reimplement with `filter`
func justEvens2(xs: [Int]) -> [Int] {
  return filter(xs) { $0 % 2 == 0 }
}
justEvens(v)


/*------------------------------------/
//  Filter already exists...
/------------------------------------*/
v
let onlyEvens = v.filter { $0 % 2 == 0 }
onlyEvens

let onlyBig = v.filter { $0 > 300 }
onlyBig


// w/ Named function
func isOdd(n: Int) -> Bool {
  return n % 2 == 1
}
v.filter(isOdd)


/*------------------------------------/
//  Reduce
/------------------------------------*/
// Consider addition
func add(xs: [Int]) -> Int {
  var result = 0 // <-- Initial value
  for x in xs {
    result += x
  }
  return result
}
v
add(v)

// How about multiplication?
func mult(xs: [Int]) -> Int {
  var result = 1 // <-- Initial value
  for x in xs {
    result *= x
  }
  return result
}
v
mult(v)

// And string concatenation?
func concat(xs: [String]) -> String {
  var result = "" // <-- Initial value
  for x in xs {
    result += x
  }
  return result
}
let words = ["The", "quick", "brown", "fox"]
concat(words)


/*-----------------------------------------/
//  Let's generalize those "reductions."
//
//  Things in common:
//    1) an inital value
//    2) a combine operation
//    3) production of a result
/-----------------------------------------*/
func reduce<A, R>(xs: [A], initialValue: R, combine: (R, A) -> R) -> R {
  var result = initialValue // (1) initial value
  for x in xs {
    result = combine(result, x) // (2) combine operation
  }
  return result // (3) produce a result
}

// try a sum
v
var reduceSum = reduce(v, 0) { $0 + $1 }
reduceSum

// you can also just pass a function or operator
reduce(v, 0, +)

// try a product
reduce(v, 1, *)

// try concatenation
reduce(words, "", +)


/*------------------------------------/
//  Map, via Reduce
/------------------------------------*/
func rmap<T, U>(xs: [T], f: T -> U) -> [U] {
  return xs.reduce([], combine: { result, x in
    return result + [f(x)]
  })
}

func rmap2<T, U>(xs: [T], f: T -> U) -> [U] {
  return xs.reduce([]) { $0 + [f($1)] }
}

let vPlusOne = rmap2(v) { $0 + 1 }
v
vPlusOne


/*------------------------------------/
//  Filter, via Reduce
/------------------------------------*/
func rfilter<T>(xs: [T], check: T -> Bool) -> [T] {
  return xs.reduce([], combine: { result, x -> [T] in
    return check(x) ? result + [x] : result
  })
}

func rfilter2<T>(xs: [T], check: T -> Bool) -> [T] {
  return xs.reduce([]) { check($1) ? $0 + [$1] : $0 }
}

let vEvens = rfilter2(v) { $0 % 2 == 0 }
vEvens


/*------------------------------------/
//  Function Composition
/------------------------------------*/
// Allows composition of two functions.
// You could think of this as a pipeline of two steps.
infix operator >>> { associativity left }
func >>> <A, B, C>(f: A -> B, g: B -> C) -> A -> C {
  return { x in g(f(x)) }
}

// step 1
func s1(x: Int) -> Int {
  return x * 2
}

// step 2
func s2(x: Int) -> Int {
  return x + 10
}

// steps 1+2 combined
let h = s1 >>> s2  // do step 1, then do step 2
h(1)


/*------------------------------------/
//  Currying
/------------------------------------*/

// You might do it like this
func add(x:Int) -> (Int) -> Int {
  return { y in x + y }
}
let addTo1000 = add(1000)
addTo1000(2)


// But that's less flexible than applying curry to an existing function
func curry <A, B, C>(f: (A, B) -> C) -> A -> B -> C {
  return { x in { y in f(x, y) } }
}

// step 1: multiply by x
// step 2: add y
// Note: Applying in reverse order is technically incorrect.
func twoStepProc(x: Int, y: Int) -> Int {
  return (1 * x) + y
}

let twoStepCurry = curry(twoStepProc)
let step2 = twoStepCurry(2) // step 1: mult by 2
step2(10) // step 2: add 10


// A real world example
func orderTotal(unitPrice: Double, quantity: Int) -> Double {
  return unitPrice * Double(quantity)
}

// price of a ticket
var ticketPrice = 11.99

// create a function to calculate ticket order totals
let ticketCalculator = curry(orderTotal)(ticketPrice)

// find the price of 10 tickets
ticketCalculator(10)


/*------------------------------------/
//  Curring by Declaration
/------------------------------------*/
func orderTotal(# unitPrice: Double)(quantity: Int) -> Double {
  return unitPrice * Double(quantity)
}
let sandwichCalculator = orderTotal(unitPrice: 4.50)
sandwichCalculator(quantity: 10)




