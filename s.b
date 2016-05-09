implement server;
include "sys.m";
     sys: Sys;
     Connection: import Sys;
include "draw.m";

node : adt {
	key : string;
	def : string;
	left : cyclic ref node;
	right : cyclic ref node;
};

avl : adt{
	root : ref node;

	height : fn(temp : ref node) : int;
    diff : fn(temp : ref node) : int;
    rr_rotation : fn(parentparent : ref node) : ref node;
    ll_rotation : fn(parentparent : ref node) : ref node;
    lr_rotation : fn(parentparent : ref node) : ref node;
    rl_rotation : fn(parentparent : ref node) : ref node;
    balance : fn(temp : ref node) : ref node;
    insert : fn(head : ref node, word : string, meaning : string);
    inorder : fn(tree : ref node);
    search : fn(tree : ref node, word : string) : ref node;
    max : fn (a :int, b : int) : int;
};


avl.max(a :int, b : int) : int{
	if(a > b){
		return a;
	}else{
		return b;
	}
}


avl.height(temp : ref node) : int{
    h := 0;
    if (temp != nil)
    {
        l_height := avl.height (temp.left);
        r_height := avl.height (temp.right);
        max_height := avl.max (l_height, r_height);
        h := max_height + 1;
    }
    return h;
}

avl.lr_rotation(parent : ref node) : ref node{
    temp : ref node;
    temp = parent.left;
    parent.left = avl.rr_rotation (temp);
    return avl.ll_rotation (parent);
}

avl.rl_rotation(parent : ref node) : ref node
{ 
    temp : ref node; 
    temp = parent.right; 
    parent.right = avl.ll_rotation (temp); 
    return avl.rr_rotation (parent); 
}

avl.ll_rotation(parent : ref node) : ref node{
    temp : ref node;
    temp = parent.left;
    parent.left = temp.right;
    temp.right = parent;
    return temp;
}

avl.rr_rotation(parent : ref node) : ref node{
    temp : ref node;
    temp = parent.right;
    parent.right = temp.left;
    temp.left = parent;
    return temp;

}

avl.diff(temp : ref node) : int{
    l_height := avl.height (temp.left);
    r_height := avl.height (temp.right);
    b_factor := l_height - r_height;
    return b_factor;
}



avl.balance(temp : ref node) : ref node{
    bal_factor := avl.diff (temp);
    if (bal_factor > 1)
    {
        if (avl.diff (temp.left) > 0)
            temp = avl.ll_rotation (temp);
        else
            temp = avl.lr_rotation (temp);
    }
    else if (bal_factor < -1)
    {
        if (avl.diff (temp.right) > 0)
            temp = avl.rl_rotation (temp);
        else
            temp = avl.rr_rotation (temp);
    }
    return temp;
}

avl.insert(head : ref node, word : string, meaning : string){
	if (word < head.key)
    {
    	if(head.left != nil){
    		avl.insert(head.left, word, meaning);
    		head = avl.balance (head);
    	}else{
    		head.left = ref node(word, meaning, nil, nil);
    	}
        
    }else{
    	if(head.right != nil){
    		avl.insert(head.right, word, meaning);
    		head = avl.balance (head);
    	}else{
    		head.right = ref node(word, meaning, nil, nil);
    	}
    }
}


avl.inorder(tree : ref node){
    if (tree == nil)
        return;
    avl.inorder (tree.left);
    sys->print("%s : %s", tree.key, tree.def);
    sys->print("\n");
    avl.inorder(tree.right);
}
server: module {
	init: fn(nil: ref Draw->Context, argv: list of string);
};


init(nil: ref Draw->Context, argv: list of string){
	sys = load Sys Sys->PATH;

	(n,conn) := sys->announce("tcp!*!6666");

	if(n < 0){
		sys->print("Announce failed!\n");
		exit;
	}

	while(1){
		listen(conn);
	}
}

listen(conn: Connection){
	buf := array [sys->ATOMICIO] of byte;
	(status,c) := sys->listen(conn);
	if(status < 0){
		sys->print("Listen failed!\n");
		exit;
	}
	rfd := sys->open(conn.dir+"/remote",Sys->OREAD);
	n := sys->read(rfd,buf,len buf);
	sys->print("New connection!\n");
	spawn handler(c);
}

avl.search(tree : ref node, word : string) : ref node{
    if (tree != nil) {
        if (word == tree.key) {
            return tree;
        }
      else if (word < tree.key) {
          
            return avl.search(tree.left, word);
        }
        else{
            return avl.search(tree.right, word);
        }
    }
    else {
        return nil;
    }
}


handler(conn: Connection){
	buf := array[sys->ATOMICIO] of byte;
    buff := array[sys->ATOMICIO] of byte;
	rdfd := sys->open(conn.dir+"/data",Sys->OREAD);
	wdfd := sys->open(conn.dir+"/data",Sys->OWRITE);
	rfd := sys->open(conn.dir+"/remote",Sys->OREAD);
	request : string;
	sys->print("Server wainting for client\n");
	n := sys->read(rfd, buf, len buf);
	r : avl;
	h := ref node("girl", "a female child", nil, nil);
    i := 1;
    fd := sys->open("cool.txt", sys->OREAD);
    n2 := sys->read(fd, buff, len buff);
    dic := string buff[:n2];
    word : string;
    d : string;
    def : string;
    word = "";
    d = "";
    def = "";
    while(i < n2){
        if(dic[i-1:i] == ":"){
            d = word;
            word = "";
        }else if(dic[i-1:i] == "."){
            def = word;
            word = "";
            r.insert(h, d, def); 
            d = "";
            def = "";
        }else{
            word += dic[i-1:i];
        }
        i++;
    }
    r.insert(h, "name", "someones name"); 
    r.insert(h, "boys", "small men"); 
    r.insert(h, "game", "done for fun"); 
	sys->print("\nhttpServe: Got new connection from (incomplete) %s\n", string buf[:n]);
	
	while(msg := sys->read(rdfd, buf, len buf)){
		request = string buf[0:4];
		sys->print("Server received request from a client.\n");
		sys->print("Request: %s\n", request);
        if(r.search(h, request) == nil){
            sys->write(wdfd, array of byte "not found", len "not found");
        }else{
            sys->write(wdfd, array of byte r.search(h, request).def, len r.search(h, request).def);
        }
        sys->print("Reply sent to client\n\n");
		
		
	}	
}