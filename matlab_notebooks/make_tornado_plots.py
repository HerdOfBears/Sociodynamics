"""
jmenard
2020-06-20

script to make tornado plots using plotly rather than matlab.
Plotly makes beautiful plots. 
"""
import numpy as np
import pandas as pd

import plotly.graph_objects as go
import matplotlib.pyplot as plt


def main():
    dir_name = "C:\\Users\\Jyler Menard\\Documents\\Projects\\socioclimate\\S2019_rpt_sociodynamics_data\\tornadoPlots\\"
    df_data = pd.read_csv(dir_name+"sensiAnalysis_heq1.csv",header=None)
    df_data_names = pd.read_csv(dir_name+"sensiAnalysis_heq1_names.csv",header=None)
    df_data_names_latex = pd.read_csv(dir_name+"sensiAnalysis_heq1_names_latex.csv",header=None)

    data_names = df_data_names.values
    data_names = data_names.T

    data_names_latex = df_data_names_latex.values
    data_names_latex = data_names_latex.T


    df_data.index = data_names_latex[:,0]


    ### Sort based on length of bar
    maxT = df_data.max(axis=1)
    minT = df_data.min(axis=1)
    bar_lengths = np.abs(maxT-df_data.values[:,1])+np.abs(minT-df_data.values[:,1])
    bar_lengths.sort_values(ascending=True,inplace=True)
    sorted_names = (bar_lengths.index.values)

    ### Make figure using plotly        
    fig = go.Figure()
    fig.add_trace(go.Bar(
        x=df_data.values[:,0]-df_data.values[:,1],
        y=data_names_latex[:,0],
        base=df_data.values[0,1],
        name='Lower Value',
    #     width=1.5,
        orientation='h',
        marker=dict(
            color='rgba(246, 78, 139, 0.6)',
            line=dict(color='rgba(246, 78, 139, 1.0)', width=3)
        )
    ))
    fig.add_trace(go.Bar(
        y=data_names_latex[:,0],
        x=df_data.values[:,2]-df_data.values[:,1],
        base=df_data.values[0,1],
        name='Upper Value',
    #     width=1.5,
        orientation='h',
        marker=dict(
            color='rgba(58, 71, 80, 0.6)',
            line=dict(color='rgba(58, 71, 80, 1.0)', width=3)
        )
    ))


    fig.update_layout(barmode='stack', 
                    yaxis={'categoryorder':'array', 'categoryarray':sorted_names})
    fig.update_yaxes(showgrid=True, gridwidth=0.5, gridcolor='Black', dtick=1)
    # fig.save()
    fig.show()
    fig.write_image(dir_name+"fig1.svg")
    # plotly.show(fig,filename="latex")