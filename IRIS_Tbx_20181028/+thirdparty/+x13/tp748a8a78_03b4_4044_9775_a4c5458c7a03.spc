# X12-ARIMA spec file default template.

# -The IRIS Toolbox.
# -Copyright (c) 2007-2013 IRIS Solutions Team.

series {
    data = (
        55.85000000
    56.86000000
    57.93000000
    58.67000000
    59.84000000
    60.61000000
    63.65000000
    64.61000000
    67.80000000
    68.30000000
    69.70000000
    69.43000000
    69.81000000
    69.93000000
    70.56000000
    70.78000000
    72.35000000
    72.54000000
    73.41000000
    73.76000000
    75.40000000
    76.29000000
    77.47000000
    76.99000000
    78.22000000
    78.04000000
    77.97000000
    77.40000000
    77.94000000
    78.09000000
    77.96000000
    78.03000000
    79.79000000
    80.14000000
    80.44000000
    80.41000000
    81.07000000
    81.39000000
    81.94000000
    82.33000000
    83.37000000
    83.78000000
    84.35000000
    83.56000000
    84.44000000
    85.56000000
    86.21000000
    87.31000000
    90.63000000
    91.32000000
    91.93000000
    91.41000000
    92.58000000
    92.63000000
    92.09000000
    91.82000000
    93.13000000
    93.68000000
    93.81000000
    93.66000000
    94.76000000
    95.34000000
    95.45000000
    95.91000000
    98.25000000
    98.60000000
    98.56000000
    98.62000000
    99.96000000
    100.11000000
    99.83000000
    99.76000000
    100.16000000

    )
    period = 4
    start = 1996.1
    precision = 5
    decimals = 5
    
}

transform {
    function = log
}

automdl {
    maxorder = (2 1)
}

forecast {
    maxlead = 0
    maxback = 0
    save = (forecasts backcasts)
}

estimate {
    tol = 1.000000e-05
    maxiter = 1500
    save = (model)
}

#regression regression {
#regression #tdays     variables = ($tdays$)
#regression #dummy     start = $dummy_startyear$.$dummy_startper$
#regression #dummy     user = ($dummy_name$)
#regression #dummy     usertype = $dummy_type$
#regression #dummy     data = (
#regression #dummy     $dummy_data$
#regression #dummy     )    
#regression }

x11 {
    mode = mult
    save = (d11 )
    appendbcst = no
    appendfcst = no
}
