defmodule Main do
    @name :server
    def main(args) do  

        if  String.contains?(Enum.at(args,0),".") do 
            {_, options, _} = OptionParser.parse(args, switches: [question: :string],)# get the command line arguments and parse them

            Bar.initClientNode(to_string(options)) #to start the node, set the cookie and connect with the server node
            nprocclient=:erlang.system_info(:logical_processors) #calculate no pf logical processors
            cspawn=nprocclient*5
            client_pids=Enum.map(1..cspawn, fn (_) -> spawn(ClientModule,:client,[]) end)
            Enum.each client_pids , fn pid -> send :global.whereis_name(:server), {pid, :getBatch,"", 0} end
        else 
            Bar.initServerNode #to start the node, set the cookie

            {_, options, _} = OptionParser.parse(args, switches: [question: :string],)# get the command line arguments and parse them
            {numberOfLeadingZeros,_} = Integer.parse("#{options}")            
            # Create a server pid to Listen to the client
            server_pid= spawn(ServerModule,:server,[numberOfLeadingZeros])# to test    
            #register the servers PID so that the client can contact it using it's global name
            :global.register_name(@name, server_pid)
            #Create a worked pids to mine coins locally
            nproc=:erlang.system_info(:logical_processors)
            nspawn=nproc*4
            pids = Enum.map(1..nspawn, fn (_) -> spawn(ServerModule,:server,[numberOfLeadingZeros]) end)                        
            Enum.each pids , fn pid -> send pid, {:mineBitCoin,numberOfLeadingZeros,0,""} end    
            
            
        end
    
    
    loop()
    
    #:timer.sleep(100000000)# to avoid the main program from stopping while other process are working asynchronously
  end

  def loop do
    loop()
  end
end