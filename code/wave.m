function [ Ez_src, Hy_src, STEPS ] = wave( dx, dt, source,params )
%WAVE Summary of this function goes here
%   Detailed explanation goes here
    global c0
    f= source.fmax;
    
    % +++ We let the simulation a few periods of the pulse, and a delay t0
    tau = 0.5/f;
    t_sim = params.TIME_MULT*100*tau;
    t0 = 4*tau;
    
    % +++ We get the time sampling 
    STEPS = ceil(t_sim/dt);
    
    % +++ Now we init the vectors for storing the inc wave on 1D space
    Ez_src = zeros(1,STEPS);
    Hy_src = zeros(1,STEPS);
    
    % +++ The time vector
    t = (0:STEPS-1)*dt;
    % +++ Angular frequancy

    
%     delta = -1.0*(dx/(2*c0)+dt);
    delta = -sqrt(2)*dt;
    %delta =dt; % -sqrt(e0/u0)
    %delta = -dx/c0-dt/2;
    % +++ Now we create the source, taking type_src into account
    switch (source.type)
        case 'sinusoid'      % Sinusoid
            f_sinus = source.f;
            omega = f_sinus*2*pi;
            Ez_src =  sin(omega*t-t0);
            Hy_src =  -1*sin(omega*t-t0-delta);
            return
        case 'gaussian'      % Gaussian
            Ez_src =  exp(-((t-t0)/tau).^2);
            Hy_src =  -1*exp(-((t-t0+delta)/tau).^2);
            return
        case 'mexico'      % Mexican hat
            Ez_src =  (1.0 - 2.0*(pi^2)*(f^2)*((t-t0).^2)) .* exp(-(pi^2)*(f^2)*((t-t0).^2));
            Hy_src =  -1*(1.0 - 2.0*(pi^2)*(f^2)*((t-t0).^2)) .* exp(-(pi^2)*(f^2)*((t-t0).^2));
            return
        case 'monogaussian'      % Gaussian
            f_sinus = source.f;
            omega = f_sinus*2*pi;
            Ez_src =  exp(-((t-t0)/tau).^2).*sin((t-t0)*omega);
            Hy_src =  -1*exp(-((t-t0+delta)/tau).^2).*sin((t-t0+delta)*omega);
            return
        case 'zgaussian'      % Complex gaussian
            Ez_src =  exp(-((t-t0)/tau).^2).*exp(-1i*2*pi*f*(t-t0));
            Hy_src =  -1*exp(-((t-t0+delta)/tau).^2).*exp(-1i*2*pi*f*(t-t0+delta));
            return
    end
    
    disp('The specified source is not available.');
end

