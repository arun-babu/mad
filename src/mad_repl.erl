-module(mad_repl).
-compile(export_all).

load_config() ->
   Config = filelib:wildcard("rels/*/files/sys.config"),
   case Config of
      [] -> skip;
      File ->
            {ok,[Apps]} = file:consult(File),
            [ begin %io:format("~p:~n",[App]),
              [ begin
%              io:format("\t{~p,~p}~n",[K,V]),
              application:set_env(App,K,V) end || {K,V} <- Cfg ] end || {App,Cfg} <- Apps]
             end.

load_apps([]) -> [ application:start(A) ||A<-mad_plan:applist()];
load_apps(Params) -> [application:ensure_all_started(list_to_atom(A))||A<-Params].

main(Params) -> 
    Path = filelib:wildcard("{apps,deps}/*/ebin") ++ 
           filelib:wildcard(code:root_dir() ++ 
              "/lib/{compiler,syntax_tools,tools,mnesia,reltool,xmerl,crypto,kernel,stdlib}-*/ebin"),
    code:set_path(Path),
    io:format("CodePath: ~p~n",[code:get_path()]),
    load_config(), load_apps(Params), user_drv:start(), 
     timer:sleep(infinity).
