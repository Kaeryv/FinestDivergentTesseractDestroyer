
A = magic(100);

B = 1:100;

tic
B = repmat(B,100,1);

for i=1:100
   C =A.*(i*B);
end
disp(toc)

tic
for i=1:100
   bsxfun(@times,A,B); 
end

disp(toc);

