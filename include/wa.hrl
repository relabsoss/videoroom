-include_lib("eknife/include/eknife.hrl").
-include_lib("kernel/include/file.hrl").

% config

-define(CONFIG(Key, Default), application:get_env(wa, Key, Default)).
-define(STEP, ?S2MS(1)).
