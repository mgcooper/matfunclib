function list = listallmfunctions
list1 = getlist(getenv('MATLABFUNCTIONPATH'),'*m','subdirs',true);
list2 = getlist(getenv('FEXFUNCTIONPATH'),'*m','subdirs',true);
list1 = list1(~contains({list1.name},'readme'));
list2 = list2(~contains({list2.name},'readme'));
list = [{list1.name} {list2.name}];