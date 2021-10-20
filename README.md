# Replication of the paper: *Global Value Chains, Trade Shocks and Jobs: An Application to Brexit*

[![Build Status](https://github.com/forsthuber92/WIOD_brexit.jl/workflows/CI/badge.svg)](https://github.com/forsthuber92/WIOD_brexit.jl/actions)
[![Coverage](https://codecov.io/gh/forsthuber92/WIOD_brexit.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/forsthuber92/WIOD_brexit.jl)

The original paper *Global Value Chains, Trade Shocks and Jobs: An Application to Brexit* was written by Hylke Vandenbussche, William Connell and Wouter Simons and 
can be accessed from the KU Leuven library via this [link](https://lirias.kuleuven.be/retrieve/535608).

The entire input data and output for this code is accessible via my personal Google Drive.

# Figures

![Figure 1:](https://raw.githubusercontent.com/forsthuber92/WIOD_brexit.jl/main/images/mfn_tariffs.png)

![Figure 2:](https://raw.githubusercontent.com/forsthuber92/WIOD_brexit.jl/main/images/soft_total.png)

![Figure 3:](https://raw.githubusercontent.com/forsthuber92/WIOD_brexit.jl/main/images/hard_total.png)

# Tables

<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<style>
  table, td, th {
      border-collapse: collapse;
      font-family: sans-serif;
  }

  td, th {
      border-bottom: 0;
      padding: 4px
  }

  tr:nth-child(odd) {
      background: #eee;
  }

  tr:nth-child(even) {
      background: #fff;
  }

  tr.header {
      background: navy !important;
      color: white;
      font-weight: bold;
  }

  tr.subheader {
      background: lightgray !important;
      color: black;
  }

  tr.headerLastRow {
      border-bottom: 2px solid black;
  }

  th.rowNumber, td.rowNumber {
      text-align: right;
  }

</style>
<body>
<table>
  <thead>
    <tr class = "header">
      <th style = "text-align: right;">iso3</th>
      <th style = "text-align: right;">direct_soft</th>
      <th style = "text-align: right;">direct_hard</th>
      <th style = "text-align: right;">indirect_soft</th>
      <th style = "text-align: right;">indirect_hard</th>
      <th style = "text-align: right;">total_soft</th>
      <th style = "text-align: right;">total_hard</th>
    </tr>
    <tr class = "subheader headerLastRow">
      <th style = "text-align: right;">Any</th>
      <th style = "text-align: right;">Any</th>
      <th style = "text-align: right;">Any</th>
      <th style = "text-align: right;">Any</th>
      <th style = "text-align: right;">Any</th>
      <th style = "text-align: right;">Any</th>
      <th style = "text-align: right;">Any</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style = "text-align: right;">AUT</td>
      <td style = "text-align: right;">-330.02</td>
      <td style = "text-align: right;">-1175.49</td>
      <td style = "text-align: right;">-148.653</td>
      <td style = "text-align: right;">-557.903</td>
      <td style = "text-align: right;">-478.673</td>
      <td style = "text-align: right;">-1733.39</td>
    </tr>
    <tr>
      <td style = "text-align: right;">BEL</td>
      <td style = "text-align: right;">-1566.09</td>
      <td style = "text-align: right;">-5829.81</td>
      <td style = "text-align: right;">-775.694</td>
      <td style = "text-align: right;">-3038.78</td>
      <td style = "text-align: right;">-2341.79</td>
      <td style = "text-align: right;">-8868.59</td>
    </tr>
    <tr>
      <td style = "text-align: right;">BGR</td>
      <td style = "text-align: right;">-54.2285</td>
      <td style = "text-align: right;">-194.836</td>
      <td style = "text-align: right;">-17.7742</td>
      <td style = "text-align: right;">-65.0485</td>
      <td style = "text-align: right;">-72.0027</td>
      <td style = "text-align: right;">-259.885</td>
    </tr>
    <tr>
      <td style = "text-align: right;">CYP</td>
      <td style = "text-align: right;">-39.1917</td>
      <td style = "text-align: right;">-124.688</td>
      <td style = "text-align: right;">-9.35639</td>
      <td style = "text-align: right;">-29.3899</td>
      <td style = "text-align: right;">-48.5481</td>
      <td style = "text-align: right;">-154.078</td>
    </tr>
    <tr>
      <td style = "text-align: right;">CZE</td>
      <td style = "text-align: right;">-321.174</td>
      <td style = "text-align: right;">-1248.43</td>
      <td style = "text-align: right;">-188.033</td>
      <td style = "text-align: right;">-758.73</td>
      <td style = "text-align: right;">-509.207</td>
      <td style = "text-align: right;">-2007.16</td>
    </tr>
    <tr>
      <td style = "text-align: right;">DEU</td>
      <td style = "text-align: right;">-4955.44</td>
      <td style = "text-align: right;">-18161.1</td>
      <td style = "text-align: right;">-1454.71</td>
      <td style = "text-align: right;">-5555.44</td>
      <td style = "text-align: right;">-6410.16</td>
      <td style = "text-align: right;">-23716.6</td>
    </tr>
    <tr>
      <td style = "text-align: right;">DNK</td>
      <td style = "text-align: right;">-711.016</td>
      <td style = "text-align: right;">-2371.58</td>
      <td style = "text-align: right;">-222.718</td>
      <td style = "text-align: right;">-746.809</td>
      <td style = "text-align: right;">-933.734</td>
      <td style = "text-align: right;">-3118.38</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ESP</td>
      <td style = "text-align: right;">-1393.82</td>
      <td style = "text-align: right;">-5550.97</td>
      <td style = "text-align: right;">-244.035</td>
      <td style = "text-align: right;">-996.898</td>
      <td style = "text-align: right;">-1637.85</td>
      <td style = "text-align: right;">-6547.87</td>
    </tr>
    <tr>
      <td style = "text-align: right;">EST</td>
      <td style = "text-align: right;">-25.9483</td>
      <td style = "text-align: right;">-84.252</td>
      <td style = "text-align: right;">-11.462</td>
      <td style = "text-align: right;">-39.6108</td>
      <td style = "text-align: right;">-37.4104</td>
      <td style = "text-align: right;">-123.863</td>
    </tr>
    <tr>
      <td style = "text-align: right;">FIN</td>
      <td style = "text-align: right;">-232.833</td>
      <td style = "text-align: right;">-808.721</td>
      <td style = "text-align: right;">-107.871</td>
      <td style = "text-align: right;">-381.234</td>
      <td style = "text-align: right;">-340.704</td>
      <td style = "text-align: right;">-1189.95</td>
    </tr>
    <tr>
      <td style = "text-align: right;">FRA</td>
      <td style = "text-align: right;">-4403.27</td>
      <td style = "text-align: right;">-14978.7</td>
      <td style = "text-align: right;">-824.355</td>
      <td style = "text-align: right;">-2960.0</td>
      <td style = "text-align: right;">-5227.62</td>
      <td style = "text-align: right;">-17938.7</td>
    </tr>
    <tr>
      <td style = "text-align: right;">GRC</td>
      <td style = "text-align: right;">-101.377</td>
      <td style = "text-align: right;">-355.838</td>
      <td style = "text-align: right;">-13.3973</td>
      <td style = "text-align: right;">-49.0384</td>
      <td style = "text-align: right;">-114.774</td>
      <td style = "text-align: right;">-404.877</td>
    </tr>
    <tr>
      <td style = "text-align: right;">HRV</td>
      <td style = "text-align: right;">-37.7482</td>
      <td style = "text-align: right;">-123.409</td>
      <td style = "text-align: right;">-9.78869</td>
      <td style = "text-align: right;">-34.18</td>
      <td style = "text-align: right;">-47.5369</td>
      <td style = "text-align: right;">-157.589</td>
    </tr>
    <tr>
      <td style = "text-align: right;">HUN</td>
      <td style = "text-align: right;">-268.638</td>
      <td style = "text-align: right;">-996.164</td>
      <td style = "text-align: right;">-163.319</td>
      <td style = "text-align: right;">-631.112</td>
      <td style = "text-align: right;">-431.957</td>
      <td style = "text-align: right;">-1627.28</td>
    </tr>
    <tr>
      <td style = "text-align: right;">IRL</td>
      <td style = "text-align: right;">-2247.35</td>
      <td style = "text-align: right;">-9450.26</td>
      <td style = "text-align: right;">-920.803</td>
      <td style = "text-align: right;">-3721.72</td>
      <td style = "text-align: right;">-3168.16</td>
      <td style = "text-align: right;">-13172.0</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ITA</td>
      <td style = "text-align: right;">-1914.79</td>
      <td style = "text-align: right;">-7129.44</td>
      <td style = "text-align: right;">-288.462</td>
      <td style = "text-align: right;">-1140.1</td>
      <td style = "text-align: right;">-2203.25</td>
      <td style = "text-align: right;">-8269.54</td>
    </tr>
    <tr>
      <td style = "text-align: right;">LTU</td>
      <td style = "text-align: right;">-100.048</td>
      <td style = "text-align: right;">-375.919</td>
      <td style = "text-align: right;">-84.3355</td>
      <td style = "text-align: right;">-315.632</td>
      <td style = "text-align: right;">-184.384</td>
      <td style = "text-align: right;">-691.551</td>
    </tr>
    <tr>
      <td style = "text-align: right;">LUX</td>
      <td style = "text-align: right;">-87.2344</td>
      <td style = "text-align: right;">-274.659</td>
      <td style = "text-align: right;">-62.2029</td>
      <td style = "text-align: right;">-198.551</td>
      <td style = "text-align: right;">-149.437</td>
      <td style = "text-align: right;">-473.21</td>
    </tr>
    <tr>
      <td style = "text-align: right;">LVA</td>
      <td style = "text-align: right;">-35.2601</td>
      <td style = "text-align: right;">-120.56</td>
      <td style = "text-align: right;">-14.2773</td>
      <td style = "text-align: right;">-50.9897</td>
      <td style = "text-align: right;">-49.5373</td>
      <td style = "text-align: right;">-171.55</td>
    </tr>
    <tr>
      <td style = "text-align: right;">MLT</td>
      <td style = "text-align: right;">-101.01</td>
      <td style = "text-align: right;">-307.339</td>
      <td style = "text-align: right;">-18.4147</td>
      <td style = "text-align: right;">-56.5135</td>
      <td style = "text-align: right;">-119.425</td>
      <td style = "text-align: right;">-363.853</td>
    </tr>
    <tr>
      <td style = "text-align: right;">NLD</td>
      <td style = "text-align: right;">-3318.56</td>
      <td style = "text-align: right;">-11858.1</td>
      <td style = "text-align: right;">-2320.0</td>
      <td style = "text-align: right;">-8230.39</td>
      <td style = "text-align: right;">-5638.56</td>
      <td style = "text-align: right;">-20088.5</td>
    </tr>
    <tr>
      <td style = "text-align: right;">POL</td>
      <td style = "text-align: right;">-1000.36</td>
      <td style = "text-align: right;">-3660.51</td>
      <td style = "text-align: right;">-307.812</td>
      <td style = "text-align: right;">-1164.69</td>
      <td style = "text-align: right;">-1308.18</td>
      <td style = "text-align: right;">-4825.2</td>
    </tr>
    <tr>
      <td style = "text-align: right;">PRT</td>
      <td style = "text-align: right;">-227.431</td>
      <td style = "text-align: right;">-917.939</td>
      <td style = "text-align: right;">-58.386</td>
      <td style = "text-align: right;">-253.041</td>
      <td style = "text-align: right;">-285.817</td>
      <td style = "text-align: right;">-1170.98</td>
    </tr>
    <tr>
      <td style = "text-align: right;">ROU</td>
      <td style = "text-align: right;">-145.801</td>
      <td style = "text-align: right;">-562.993</td>
      <td style = "text-align: right;">-46.0765</td>
      <td style = "text-align: right;">-177.069</td>
      <td style = "text-align: right;">-191.877</td>
      <td style = "text-align: right;">-740.062</td>
    </tr>
    <tr>
      <td style = "text-align: right;">SVK</td>
      <td style = "text-align: right;">-455.848</td>
      <td style = "text-align: right;">-1553.66</td>
      <td style = "text-align: right;">-167.136</td>
      <td style = "text-align: right;">-612.568</td>
      <td style = "text-align: right;">-622.984</td>
      <td style = "text-align: right;">-2166.23</td>
    </tr>
    <tr>
      <td style = "text-align: right;">SVN</td>
      <td style = "text-align: right;">-36.2906</td>
      <td style = "text-align: right;">-136.428</td>
      <td style = "text-align: right;">-19.7292</td>
      <td style = "text-align: right;">-77.9237</td>
      <td style = "text-align: right;">-56.0198</td>
      <td style = "text-align: right;">-214.352</td>
    </tr>
    <tr>
      <td style = "text-align: right;">SWE</td>
      <td style = "text-align: right;">-1046.01</td>
      <td style = "text-align: right;">-3780.87</td>
      <td style = "text-align: right;">-514.873</td>
      <td style = "text-align: right;">-1874.69</td>
      <td style = "text-align: right;">-1560.89</td>
      <td style = "text-align: right;">-5655.56</td>
    </tr>
  </tbody>
</table>
</body>
</html>