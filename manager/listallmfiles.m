function list = listallmfiles
list = getlist(getenv('MATLABUSERPATH'),'*m','subdirs',true);
list = list(~contains({list.name},'readme'));