from Functions import *


def clearEntry(event, entry):
    entry.delete(0, END)
    return


def add_user_figure(figure_list, entry):
    figure = entry.get()
    if re.fullmatch(figure_pattern, figure):
        result = []
        tmp = re.split(r'\D*', figure)
        res = [int(i) for i in list(filter(None, tmp))]
        for i in range (0, len(res), 2):
            result.append([res[i], res[i+1]])
        figure_list.append(result)
    entry.delete(0, END)
    entry.insert(0, "фигура")
    return


def add_figure_to_figures(number, figure_list):
    figure_list.append(default_figure_list[number])
    return


def show_figures_list(real_figures):
    extra_window = Toplevel()
    extra_window.title("Список введённых фигур.")
    can = Canvas(extra_window, bg="white")
    can.pack(side=TOP, padx=10, pady=10)

    x = x_maximum = 0
    y = y_maximum = 0
    for figure in real_figures:
        cur_x = x
        cur_y = y
        color = generate_random_color()
        for square in figure:
            x += square[0]*10
            y += square[1]*10
            can.create_rectangle(x, y, x+10, y+10, fill=color)
            x_maximum = max(x, x_maximum)
            y_maximum = max(y, y_maximum)
            x = cur_x
            y = cur_y
        x = x_maximum + 10
        if x > 300:
            x = x_maximum = 0
            y = y_maximum + 10
    return


def solve(real_figures, width_entry, height_entry, canvas):
    try:
        width = int(width_entry.get())
        height = int(height_entry.get())

        SwiProlog = Prolog()
        SwiProlog.consult(path_to_tetris)

        result = []
        result_dict = SwiProlog.query("main(" + str(width) + ", " +
                                      str(height) + ", " + str(real_figures) + \
                                      ", Result).")
        for res_dict in result_dict:
            result = res_dict['Result']
        #print(result)
        canvas.delete("all")
        
        x = 0
        y = 0
        for figure in result:
            color=generate_random_color()
            for square in figure:
                x += square[0]*40
                y += square[1]*40
                canvas.create_rectangle(x, y, x+40, y+40, fill=color)
                x = 0
                y = 0
        
    except:
        messagebox.showinfo("Сообщение об ошибке.",
                            "Ширина и высота должны быть целыми числами!")
    
    width_entry.delete(0, END)
    width_entry.insert(0, "ширина")
    height_entry.delete(0, END)
    height_entry.insert(0, "высота")
    

def clear_figure_list(real_figures):
    #print(real_figures)
    real_figures.clear()
    #print(real_figures)
    return
        

if __name__ == "__main__":
    figures_list = []
    
    root = Tk()
    root.title(window_title)
    root.iconbitmap(icon_path)

    generate_window_size(root, window_width, window_height)

    input_frame = Frame(root)
    input_frame.pack(side=LEFT)
    input_labelframe = LabelFrame(input_frame, text=input_labelframe_text,
                                  font=standart_header_font,
                                  relief=standart_relief)
    input_labelframe.pack(side=TOP, padx=10, pady=10)

    width_frame = Frame(input_labelframe)
    width_label = Label(width_frame, text=width_label_text,
                        font=standart_font)
    width_label.pack(side=LEFT, padx=10, pady = 10)
    width = StringVar(value='ширина')
    width_entry = Entry(width_frame, width=20, textvariable=width,
                        font=standart_font, relief=standart_entry_relief,
                        fg="gray", highlightcolor="black")
    width_entry.pack(side=LEFT, padx=10, pady = 10)
    width_entry.bind('<Button-1>', lambda event, entry=width_entry:
                     clearEntry(event, entry))
    width_frame.pack()

    height_frame = Frame(input_labelframe)
    height_label = Label(height_frame, text=height_label_text,
                         font=standart_font)
    height_label.pack(side=LEFT, padx=10, pady = 10)
    height = StringVar(value='высота')
    height_entry = Entry(height_frame, width=20, textvariable=height,
                         font=standart_font, relief=standart_entry_relief,
                         fg="gray", highlightcolor="black")
    height_entry.pack(side=LEFT, padx=10, pady = 10)
    height_entry.bind('<Button-1>', lambda event, entry=height_entry:
                      clearEntry(event, entry))
    height_frame.pack()

    figure_frame = Frame(input_labelframe)
    figure_frame.pack()
    add_figure_label = Label(figure_frame, text=add_figure_label_text,
                             font=standart_font)
    add_figure_label.pack(side=LEFT, padx=10, pady = 10)
    add_figure = StringVar(value='фигура')
    add_figure_entry = Entry(figure_frame, width=20, textvariable=add_figure,
                             font=standart_font, relief=standart_entry_relief,
                             fg="gray", highlightcolor="black")
    add_figure_entry.pack(side=LEFT, padx=10, pady = 10)
    add_figure_entry.bind('<Button-1>', lambda event, entry=add_figure_entry: clearEntry(event, entry))
    add_figure_button = Button(input_labelframe, text="добавить фигуру",
                               font=standart_font, relief=standart_relief,
                               command=lambda real_figures=figures_list,
                               entry=add_figure_entry:
                               add_user_figure(real_figures, entry))
    add_figure_button.pack(side=BOTTOM, padx=10, pady=10)

    figure_list_frame = LabelFrame(input_frame, text=figure_label_text,
                                   font=standart_header_font)
    figure_list_frame.pack(side=TOP, padx=10, pady=10)

    photo = []
    figures = []
    photo_image = []
    row_1_frame = Frame(figure_list_frame)
    row_1_frame.pack(side=TOP)
    row_2_frame = Frame(figure_list_frame)
    row_2_frame.pack(side=TOP)
    row_3_frame = Frame(figure_list_frame)
    row_3_frame.pack(side=TOP)
    spec_frame = row_1_frame
    for i in range(1, 10, 1):
        photo.append(PhotoImage(file="img/figures/figure_" + str(i) + ".png"))
        photo_image.append(photo[i-1].subsample(5, 5))
        if (i >= 5):
            spec_frame = row_2_frame
        if (i >= 9):
            spec_frame = row_3_frame
        figures.append(Button(spec_frame, image=photo_image[i-1], padx = 3,
                              bg="white", command=lambda number=i-1,
                              real_figures=figures_list:
                              add_figure_to_figures(number, real_figures)))
        figures[i-1].pack(side=LEFT, padx=10, pady=10)

    canvas = Canvas(root, width=500, height=550, bg="white")
    canvas.pack(side=RIGHT, padx=10, pady=10)

    button_frame = Frame(input_frame)
    button_frame.pack(side=TOP)

    show_figures_button = Button(button_frame,
                                 text="отобразить список\nвведённых фигур",
                                 relief=standart_relief, font=standart_font,
                                 command=lambda real_figures=figures_list:
                                 show_figures_list(real_figures))
    show_figures_button.pack(side=LEFT, padx=10, pady=10)
    solve_button = Button(button_frame, text="заполнить область",
                          relief=standart_relief, font=standart_font,
                          command=lambda real_figures=figures_list,
                          w_entry=width_entry, h_entry=height_entry,
                          can=canvas:
                          solve(real_figures, w_entry, h_entry, can))
    solve_button.pack(side=LEFT, padx=10, pady=10)
    clear_figures = Button(button_frame, text="очистить список фигур",
                           relief=standart_relief, font=standart_font,
                           command=lambda real_figures=figures_list:
                           clear_figure_list(real_figures))
    clear_figures.pack(side=LEFT, padx=10, pady=10)
    
    root.mainloop()
