# MicroGene
Compact GeSA-similar core for BaseGeSA

## Ok, What is GeSA? ##

GeSA is a (not yet implemented) **Genetic System Architecture**.

GeSA is designed to (abstractly) mimic behavior of biological genetic code — and still be a computational
system architecture designed not for biology, but for normal software development.

## Why? ##

Ok, imagine: you take a complex project, write it with a huge team of developers over the course of
several years. Do you already know the result? Basically, a mess of interdependent code; and the worst
part — it is unimaginably complex to rewrite any part of it.

Yes, also, there are tons of patterns and design solutions to fix this, and what is new…

## GeSA ##

GeSA is designed **specifically** for complex, interdependent projects. GeSA is an architecture, where
you **do not control**:

1. Flow of data
2. Flow of execution

Instead, you define small transforming pieces, that have and input, and output (kinda like in FP), a small
procedure that performs a "test" operation on inputs, and a procedure that transforms input into output. 
Such piece is called a "Gene".

And there is a global namespaced environment, where all of the variables are stored
when not in execution.

So what you have in a single Gene:

1. Input variables
2. Match expression
3. Execution block

Input variables are guaranteed to be available and set upon execution of a match expression, and match
expression is guaranteed to be successful upon execution of the execution block. 

Nothing too complex here (yet).

There are also some limitations:

1. Gene is required to work only with its own variables
2. When working outside of its own variables, assume parallel execution

> **Q:** *How to use objects from the Gene?*
> 
> **A:** Use object reference as input.

## GeSA advantages ##

* GeSA provides parallel execution in a concept similar to Actor, but much more "functional". Each gene
  can be regarded as a function with a match statement, that produces some output.
* GeSA disconnects every single piece of your architecture into small, easily combinable and tunable "Genes",
  allowing to write programs looking at inputs and outputs, not at the whole process of transformation.
* GeSA disconnects your architecture so much, that you can also put its pieces onto different computers
  (just like actors, btw), and interconnect them effortlessly.
* GeSA allows for massive parallelism (also can be distributed).

## GeSA disadvantages ##

* GeSA is terribly heavy. MicroGene is computationally heavy, but full GeSA may actually employ DBMS
  for managing the environment and trigger-backed execution of genes.
* Writing GeSA is not simple. At least in Swift, you have not a small amount of boilerplate code (but that's
  mostly because of Swift deficiencies, which are supposed to be removed in future Swift versions).

## How it came to be ##

I designed GeSA trying to solve a very specific problem: I needed a system that would allow dynamic
computation of a simulation model. I needed to chain and distribute different commands to different
execution modules (i.e. CPU, SIMD, GPU), based on different parameters involved in the computation,
and still not be too much concerned with the layering of different models for different execution modules.

Later, I was designing a system for crawling websites, and written there tons of similar code, that was
different in too much parameters to abstract it away into functions, and still too similar to be not.

And I'm also a proponent of Actors and Reactive programming. So, here, out of all of it, came this system.

## Examples ##

Coming soon… 

For now, see [GeneTests,swift](/Tests/MicroGeneTests/GeneTests.swift) for a small (and totally unuseful and
totally wasteful) Fibonacci number calculation example.

## MicroGene ##

MicroGene is a minimal-feature implementation of the GeSA. It is intended first as a proof-of-concept, and
then as a base system for fully-featured GeSA (because if we are making the "great" architecture, why 
not write itself on that architecture, right?).

Key differences of MicroGene:

1. MicroGene is not parallel
2. MicroGene is not distributed (though it may be, but it complicates code too much)
3. MicroGene is using mostly simple iterative lookups for finding Genes that require a certain variable
4. MicroGene doesn't have expression system for the matching step. Instead, it executes a method in the
   Gene itself, that is supposed to test the values.


