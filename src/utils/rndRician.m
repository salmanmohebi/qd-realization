function r = rndRician(s, sigma, m ,n)

x = randn(m, n)*sigma + s;
y = randn(m, n)*sigma;
r = sqrt(x.^2 + y.^2);

end