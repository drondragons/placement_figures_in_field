import re
from pyswip import Prolog
from random import randint

from tkinter import *
from tkinter import messagebox


icon_path = "img/icon/icon.ico"
window_title = "Заполнение прямоугольной области введёнными фигурами."

standart_font = ("Helvetica", 10, "italic")
standart_header_font = ("Helvetica", 13, "bold")

standart_relief = "ridge"
standart_entry_relief = "groove"

input_labelframe_text = "ввод данных"
width_label_text = "Введите ширину заполняемой области:"
height_label_text = "Введите высоту заполняемой области:"
figure_label_text = "список возможных фигур"
add_figure_label_text = "Введите фигуру в виде [x1,y1], [x2,y2]...:"

path_to_tetris = "FigurePlacement.pl"
input_intro_message = "Заполняемая область должна быть прямоугольной.\n"

default_figure_list = [[[2, 1], [2, 2], [2, 3], [1, 2], [3, 2]],
                       [[1, 2], [1, 1], [2, 1], [3, 1]],
                       [[1, 1]],
                       [[1, 1], [2, 1], [3, 1]],
                       [[1, 1], [2, 1]],
                       [[1, 1], [2, 1], [3, 1], [2, 2]],
                       [[1, 2], [1, 1], [2, 1]],
                       [[1, 1], [1, 2], [2, 2], [2, 1]],
                       [[1, 1], [2, 1], [3, 1], [4, 1]]]

window_width = 1100
window_height = 600

figure_pattern = r'^\[(\[(\d)+, (\d)+\]\, )*\[(\d)+, (\d)+\]\]{1}$'


def generate_random_color():
    hash_sign = "#"
    red = ("%02x" % randint(0, 255))
    green = ("%02x" % randint(0, 255))
    blue = ("%02x" % randint(0, 255))
    return hash_sign + red + green + blue


def generate_window_size(root, width, height):
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    
    x = screen_width/2 - width/2
    y = screen_height/2 - height/2

    root.geometry("+%d+%d" % (x, y))
    root.resizable(False, False)
