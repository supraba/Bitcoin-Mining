defmodule ServerModule do
  def server(n) do
    receive do      
      {:mineBitCoin, n, noOfCoinsMined, str} -> # mine bitcoins         
        if str == "" do
          formString("", n, self(), noOfCoinsMined)
        else
          compute(str, noOfCoinsMined, self())
        end

      {from, :getBatch, str, numOfCoinsMined} -> # forms a list of input strings and sends it to the client to mine
        
        batchSize = 1000000
        formBatchOfStrings([], batchSize, batchSize, str, n, self(), from, numOfCoinsMined)

      {from, :printBitCoinCli, list, input, hash, str, noOfCoinsMined, processedNo, batchSize} ->
                      
        IO.puts "#{input} #{hash}"
        if processedNo == batchSize do
          send self(), {from, :getBatch, str, noOfCoinsMined}
        else      
          send from, {self(), :mineCoinsInBatch, list, n, str, batchSize, processedNo,noOfCoinsMined}
        end                
      {from, :printBitCoinServ, input, hash, noOfCoinsMined, str} ->    
        IO.puts "#{input} #{hash}"   
        send from, {:mineBitCoin, n, noOfCoinsMined, str}  

      end
    server(n)
  end

  # def printCoinsMinedByClient(from, self, inputList, hashList, noOfCoinsMined, index) do
  #   IO.puts "#{inspect from} -> [#{index}] #{Enum.at(inputList, index)} #{Enum.at(hashList, index)}"        
  # end

  def formBatchOfStrings(list, i, batchSize, str, n, self, from, numOfCoinsMined) do
    if i>0 do      
      input =  Enum.join(["92159813", :rand.uniform(100000000000)]) # to append ufid with a random nonce    
      list = list ++ [input]
      #IO.puts "hh"
      #:timer.sleep(100000)
      formBatchOfStrings(list, i-1,  batchSize, str, n, self, from, numOfCoinsMined) 
    else
      send from, {self(), :mineCoinsInBatch, list, n, str, batchSize, 0, numOfCoinsMined}                
    end
  end

  def compute(str, noOfCoinsMined, from) do
      input =  Enum.join(["92159813", :rand.uniform(100000000000)]) # to append ufid with a random nonce
      #IO.puts input
      hash =  Base.encode16(:crypto.hash(:sha256, input))|>String.downcase()
      tuple  = (:binary.match(hash, str)) # to find the index of str in hash
      if tuple != :nomatch do
        {index,_} = tuple
        if index==0 do # required number of leading zeros found             
          send from, {self(), :printBitCoinServ, input, hash, noOfCoinsMined+1,str}
        else
          compute(str, noOfCoinsMined, from)
        end
      else
        compute(str, noOfCoinsMined, from)
      end
  end

  def formString(str, n, from, noOfCoinsMined) do # recursively building the string with n zeros
    if n>0 do
      str = Enum.join([str, "0" ])
      formString(str, n-1, from, noOfCoinsMined)
    end
    if n==0 do
      compute(str, noOfCoinsMined, from)
    end
  end
end
