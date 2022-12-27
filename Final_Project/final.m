% Loading the data
pfe = readtable("PFE.csv");
d = pfe{:,2};
p = pfe{:,3};

Rt = ((p(2:end) + d(2:end))./p(1:end - 1)) - 1;
rt = log(Rt + 1);

plot(p)

DPt = d(1:end)./p(1:end); 
dpt = log(DPt);

n=length(rt);
n1=fix(n*0.5);  %estimation sample
n2=n-n1;


% For h = 1
h = 12;

%aggregate dependent variable (containing true values)
y=zeros(n-h+1,1);
for i=1:(n-h+1);
    s=0;
    for j=0:(h-1);s=s+rt(i+j);end;
    y(i)=s;
end;
y_true=y((n1+1):(n-h+1));

%historical mean
y_hm=zeros(n2-h+1,1);
for i=1:length(y_hm);
    y_hm(i)=mean(y(1:(n1-h+i)));  %expanding window
end;
MSE_hm=mean((y_hm-y_true).^2)

%direct method
y_direct=zeros(n2-h+1,1);
for i=1:length(y_direct);
    res = ols(rt(2:(n1-h+i)),[ones(n1-h+i-1,1), dpt(1:(n1-h+i-1))]);
    a_lh = res.beta(1);
    b_lh = res.beta(2);
    y_direct(i)=a_lh+b_lh*dpt(n1-1+i);  
end;

MSE_direct = mean((y_direct-y_true).^2)
R2_direct =1-MSE_direct/MSE_hm

%Moving Average Method 
y_MA=zeros(n2-h+1,1);
type = 'linear';
y_MA = movavg(y((n1+1):(n-h+1)),type,50);

MSE_MA = mean((y_MA-y_true).^2)
R2_MA =1-MSE_MA/MSE_hm



yplot_true=[y(1:n1);y_true];  %These are for plotting purpose
yplot_hm=[y(1:n1);y_hm];
yplot_direct=[y(1:n1);y_direct];
yplot_MA=[y(1:n1);y_MA];

plot(yplot_true)
hold on 
plot(yplot_hm)
plot(yplot_direct)
plot(yplot_MA)
hold off
legend('Actual', 'Historical Mean', 'Direct', 'MA');
