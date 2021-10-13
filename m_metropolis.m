clc
clear all
close all

% Define and plot target distribution
mu = [0 0]; % mean
rho = 0.998;
sigma = [1 rho; rho 1]; % covariance matrix of target

% Target "PDF"
P = @(X) mvnpdf(X, mu, sigma); % X is implicitly a vector in R2
x1 = linspace(-1, 1);
x2 = x1;
[X1 X2] = meshgrid(x1, x2);
Pcontour = reshape(P([X1(:), X2(:)]), 100, 100);
figure(1); clf; contour(X1, X2, Pcontour, [1.6 3], 'k'); axis square



% Proposal PDF
sigma2 = sqrt(sigma);   % Covariance Matrix for proposal
proposal_PDF = @(X,mu) mvnpdf(X,mu,sigma2);
sample_from_proposal_PDF = @(mu) mvnrnd(mu,sigma2);  % Function that samples from proposal PDF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lag = 200;
burnin = 1000;
N = burnin + 30*lag;
theta = zeros(N,2);
thetat = [0 0];
acc = 0;
for i=1:N-1
    theta_ast = sample_from_proposal_PDF(thetat);
    alpha = (P(theta_ast)*proposal_PDF(thetat,theta_ast))/...
            (P(thetat) *proposal_PDF(theta_ast,thetat));
    if rand <= min(alpha,1)
        thetat = theta_ast;
        a = 1;
    else
        thetat = thetat;
        a = 0;
    end
    theta(i+1,:) = thetat;
    acc = acc + a;
end
accrate = acc/(N-1)

size(theta)
figure(2)
plot(theta(:,1),theta(:,2),'k.','LineWidth',1);% hold on;
hold on; contour(x1,x2,Pcontour, [1.6 3],'--','LineWidth',2);% colormap jet; axis tight;
text(1,-1,sprintf('%g = Acceptace rate', accrate),'FontSize',11);


figure(3)
surf(x1,x2,Pcontour); grid on; shading interp;

figure(4)
subplot(2,1,1);
acf(theta(:,1),lag)
subplot(2,1,2);
acf(theta(:,2),lag)

figure(5)
scatterhist(theta(:,1),theta(:,2)); hold on; 


