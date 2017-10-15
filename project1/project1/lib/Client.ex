defmodule ClientModule do
  def client do #1
    receive do
        {from, :mineCoinsInBatch, list, numberOfLeadingZeros, str, batchSize, processedNo,numOfCoinsMined} ->
              #  IO.puts "inside mineCoinsInBatch of the client"
               if str == "" do
                    formString("", list, numberOfLeadingZeros, batchSize, processedNo,numOfCoinsMined, from)
               else
                    findCoins(str, list, batchSize, processedNo, from,numOfCoinsMined)                
               end
    end
    client()
end

  def findCoins(str, list, batchSize, index, from, numOfCoinsMined) do
    # IO.puts "#{index} #{batchSize}"
    if index == batchSize do
        send from, {self(), :getBatch, str, numOfCoinsMined}
    else
      input = Enum.at(list, index)
      hash =  Base.encode16(:crypto.hash(:sha256, input))|>String.downcase()
      tuple  = (:binary.match(hash, str)) # to find the index of str in hash
      if tuple != :nomatch do
        {startsAt,_} = tuple
        if startsAt==0 do # required number of leading zeros found
          # IO.puts "#{input} #{hash}"                
          send from, {self(), :printBitCoinCli, list, input, hash, str, numOfCoinsMined+1, index+1, batchSize}
        else
          findCoins(str, list, batchSize, index+1, from, numOfCoinsMined)        
        end
      else
        findCoins(str, list, batchSize, index+1, from, numOfCoinsMined)        
      end
    end
  end

  def formString(str, list, n, batchSize, processedNo, numOfCoinsMined,from) do # recursively building the string with n zeros
    if n>0 do
      str = Enum.join([str, "0" ])
      formString(str, list, n-1, batchSize, processedNo,numOfCoinsMined,from)
      #formString(str, n-1, from, noOfCoinsMined)
    end
    if n==0 do
      # IO.puts str
      findCoins(str, list, batchSize, processedNo, from,numOfCoinsMined)
    end
  end
  end