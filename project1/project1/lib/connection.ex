defmodule Bar do
    def initClientNode(ipadress) do
        {_,addresses}=:inet.getif()
        head_adress=to_string(elem(elem(Enum.at(addresses,0),0),0))<>"."<> to_string(elem(elem(Enum.at(addresses,0),0),1))<>"."<>to_string(elem(elem(Enum.at(addresses,0),0),2))<>"."<> to_string(elem(elem(Enum.at(addresses,1),0),3))
        fullname="client1"<>"@"<>to_string(head_adress)
        Node.start(:"#{fullname}")
        Node.set_cookie :hello
        servername="server1"<>"@"<>to_string(ipadress)
        Node.connect :"#{servername}"
        :global.sync()  
    end 
    def initServerNode do
        {_,addresses}=:inet.getif()
        head_adress=to_string(elem(elem(Enum.at(addresses,0),0),0))<>"."<> to_string(elem(elem(Enum.at(addresses,0),0),1))<>"."<>to_string(elem(elem(Enum.at(addresses,0),0),2))<>"."<> to_string(elem(elem(Enum.at(addresses,0),0),3))
        fullname="server1"<>"@"<>to_string(head_adress)
        Node.start(:"#{fullname}")
        Node.set_cookie :hello
    end   
end