APPNAME=wa
REBAR=./rebar
ERLC=erlc
COOKIE=gRPZkPvMUvHuBMn0Leuw8vzK0yeK5Cu1

.PHONY:deps

all: deps compile

./rebar:
	erl -noshell -s inets start -s ssl start \
		-eval 'httpc:request(get, {"http://github.com/downloads/basho/rebar/rebar", []}, [], [{stream, "./rebar"}])' \
		-s inets stop -s init stop
	chmod +x ./rebar

compile: $(REBAR)
	@$(REBAR) compile

clean: $(REBAR)
	@$(REBAR) clean

deps: $(REBAR)
	@$(REBAR) check-deps || (export GPROC_DIST=true; $(REBAR) get-deps)

run:
	erl +A 4 -set_cookie $(COOKIE) -pa ebin edit deps/*/ebin -sname $(APPNAME)@localhost -s $(APPNAME) -s sync

