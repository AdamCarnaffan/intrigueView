<?php

$test = ['a', 'e', 'i', 'o', 'u'];

$var = range('a','z');

$testing = function(&$param1) use ($test) {
  foreach ($param1 as $key=>$val) {
    if (in_array($val, $test)) {
      unset($param1[$key]);
    }
  }
};

$testing($var);
print_r($var);

 ?>
