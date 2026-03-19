#include <TXLib.h>
#include <stdio.h>
#include <stdbool.h>

#define MAIN_MENU    0
#define PATCHER      1
#define SUCCESS_PTCH  2
#define SUCCESS_UNPTCH 3

#define GO_PATCH_BTN 1
#define EXIT_BTN     2
#define YES_PATCH    1
#define YES_UNPATCH  4
#define RET_MENU     3

#define ORIG_HASH      5944380004466289632
#define PATHCED_HASH   7196638112475397537

struct Button
{
    double x0;
    double y0;
    double x1;
    double y1;
    COLORREF color;
    const char* text;
};

// ========================================================= ПРОТОТИПЫ ===========================================================


Button create_button (double x1, double y1, double x2, double y2, COLORREF color, const char* text);

void draw_button (Button *btn);

bool is_button_clicked (Button *btn);

int main_menu ();

int bin_patch (const char* filename, int *nextScreen);

void draw_centered_text (const char* text, int y, int fontSize, COLORREF color);

size_t hash_file (const char *filename);

int patcher (const char *filename, int selection);

void animation (const char* text, int* currentScreen);


// ======================================================= MAIN ============================================================


int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        printf("ERROR: the code file was not specified\n");
        return 1;
    }

    char* filename = argv[1];

    txCreateWindow(915, 592);
    txBegin();

    HDC back = txLoadImage("frames/hacker0001.bmp");
    
    int currentScreen = MAIN_MENU;
    int nextScreen = MAIN_MENU;

    while (!txGetAsyncKeyState(VK_ESCAPE))
    {        
        txSetFillColor(TX_WHITE);
        txClear();

        if (currentScreen != SUCCESS_PTCH && currentScreen != SUCCESS_UNPTCH)
        {
            txBitBlt(txDC(), 0, 0, 0, 0, back, 0, 0);
        }
            
        if (currentScreen == MAIN_MENU) 
        {
            int result = main_menu();

            if (result == GO_PATCH_BTN) 
            {
                currentScreen = PATCHER;
            }

            if (result == EXIT_BTN) break;
        }

        else if (currentScreen == PATCHER) 
        {
            int clicked = bin_patch(filename, &nextScreen);
            
            if (clicked) 
            {
                if (nextScreen == EXIT_BTN) break;
                currentScreen = nextScreen;
            }
        }

        else if (currentScreen == SUCCESS_PTCH)
        {
            animation("SUCCESS PATCHED", &currentScreen);
            if (currentScreen == EXIT_BTN) break;
        }

        else if (currentScreen == SUCCESS_UNPTCH)
        {
            animation("SUCCESS UNPATCHED", &currentScreen);
            if (currentScreen == EXIT_BTN) break;
        }
        
        txSleep(1);
    }

    txDeleteDC(back);
    txEnd();
    return 0;
}


// ======================================================= РАЗНЫЕ МЕНЮ ============================================================


int main_menu()
{
    static Button btn1 = create_button(257, 420, 657, 500, TX_GREEN, "Patch file");
    static Button btn2 = create_button(815, 20, 895, 60, TX_RED, "EXIT");

    draw_button(&btn1);
    draw_button(&btn2);

    draw_centered_text("BINARY PATCHER", 100, 72, TX_GREEN);

    if (is_button_clicked(&btn1)) return GO_PATCH_BTN;
    if (is_button_clicked(&btn2)) return EXIT_BTN;
    
    return 0;
}

int bin_patch(const char* filename, int *nextScreen)
{
    size_t hash_original = ORIG_HASH;
    size_t hash_patched  = PATHCED_HASH;

    size_t hash = hash_file(filename);

    if (hash == hash_original)
    {
        draw_centered_text("DO YOU WANT TO PATCH FILE?", 100, 50, TX_GREEN);

        static Button btn1 = create_button(150, 420, 400, 500, TX_GREEN, "Yes");
        static Button btn2 = create_button(515, 420, 765, 500, TX_RED, "Ret main menu");
        static Button btn3 = create_button(815, 20, 895, 60, TX_RED, "EXIT");
        draw_button(&btn1);
        draw_button(&btn2);
        draw_button(&btn3);
        
        if (is_button_clicked(&btn1)) 
        {
            *nextScreen = patcher(filename, YES_PATCH);
            return 1;
        }

        if (is_button_clicked(&btn2)) 
        {
            *nextScreen = MAIN_MENU;
            return 1;
        }

        if (is_button_clicked(&btn3)) 
        {
            *nextScreen = EXIT_BTN;
            return 1;
        }
    }

    else if (hash == hash_patched)
    {
        draw_centered_text("DO YOU WANT TO UNPATCH FILE?", 100, 50, TX_GREEN);

        static Button btn1 = create_button(150, 420, 400, 500, TX_GREEN, "Yes");
        static Button btn2 = create_button(515, 420, 765, 500, TX_RED, "Ret main menu");
        static Button btn3 = create_button(815, 20, 895, 60, TX_RED, "EXIT");

        draw_button(&btn1);
        draw_button(&btn2);
        draw_button(&btn3);
        
        if (is_button_clicked(&btn1)) 
        {
            *nextScreen = patcher(filename, YES_UNPATCH);
            return 1;
        }

        if (is_button_clicked(&btn2)) 
        {
            *nextScreen = MAIN_MENU;
            return 1;
        }

        if (is_button_clicked(&btn3)) 
        {
            *nextScreen = EXIT_BTN;
            return 1;
        }
    }

    else
    {
        draw_centered_text("FILE IS BROKEN", 100, 72, TX_RED);

        static Button btn2 = create_button(257, 420, 657, 500, TX_GREEN, "Ret main menu");
        static Button btn3 = create_button(815, 20, 895, 60, TX_RED, "EXIT");

        draw_button(&btn2);
        draw_button(&btn3);

        if (is_button_clicked(&btn2)) 
        {
            *nextScreen = MAIN_MENU;
            return 1;
        }
        
        if (is_button_clicked(&btn3)) 
        {
            *nextScreen = EXIT_BTN;
            return 1;
        }
    }
    
    return 0;
}

size_t hash_file(const char *filename)
{
    size_t hash = 5381;

    FILE *file = fopen(filename, "rb");
    if (!file) return 0;
    
    int c = 0;
    
    while ((c = fgetc(file)) != EOF)
        hash = ((hash << 5) + hash) + c;
    
    fclose(file);
    return hash;
}

int patcher(const char *filename, int selection)
{
    FILE *file = fopen(filename, "r+b");
    
    if (!file) {
        printf("Ошибка открытия файла\n");
        return MAIN_MENU;
    }
    
    fseek(file, 143, SEEK_SET);

    if (selection == YES_PATCH)
    {
        fputc(0x75, file);
        fclose(file);
        return SUCCESS_PTCH;
    }
    
    if (selection == YES_UNPATCH)
    {
        fputc(0x74, file);
        fclose(file);
        return SUCCESS_UNPTCH;
    }
    
    fclose(file);
    return MAIN_MENU;
}


void animation(const char* text, int* currentScreen)
{
    static int current_frame = 1;
    char filepath[64];
    
    sprintf(filepath, "frames/hacker%04d.bmp", current_frame);

    HDC anim_frame = txLoadImage(filepath);
  
    txBitBlt(txDC(), 0, 0, 0, 0, anim_frame, 0, 0);
    txDeleteDC(anim_frame);
    
    current_frame++;
    if (current_frame > 317) current_frame = 1;

    draw_centered_text(text, 100, 72, TX_GREEN);

    static Button btn2 = create_button(257, 450, 657, 530, TX_GREEN, "Ret main menu");
    static Button btn3 = create_button(815, 20, 895, 60, TX_RED, "EXIT");

    draw_button(&btn2);
    draw_button(&btn3);

    if (is_button_clicked(&btn2)) 
    {
        *currentScreen = MAIN_MENU;
        current_frame = 1;
    }

    if (is_button_clicked(&btn3)) 
    {
        *currentScreen = EXIT_BTN;
    }
}


// ===================================================== КНОПКИ =============================================================


    Button create_button(double x1, double y1, double x2, double y2, COLORREF color, const char* text)
{
    Button btn = {};
    btn.x0 = x1;
    btn.y0 = y1;
    btn.x1 = x2;
    btn.y1 = y2;
    btn.color = color;
    btn.text = text;

    return btn;
}

void draw_button(Button *btn)
{
    txSetColor(TX_BLACK);
    txSetFillColor(btn->color); 
    txRectangle((int)btn->x0, (int)btn->y0, (int)btn->x1, (int)btn->y1);
    
    txSetColor(TX_WHITE);
    txSelectFont("Arial", 20);

    int textWidth = txGetTextExtentX(btn->text);
    int textX = (int)btn->x0 + ((int)btn->x1 - (int)btn->x0 - textWidth) / 2;
    int textY = (int)btn->y0 + ((int)btn->y1 - (int)btn->y0 - 20) / 2;

    txTextOut(textX, textY, btn->text);
}

bool is_button_clicked(Button *btn)
{
    if (txMouseButtons() == 1)
    {
        double mx = txMouseX();
        double my = txMouseY();
        
        if (mx >= btn->x0 && mx <= btn->x1 && my >= btn->y0 && my <= btn->y1)
        {
            while (txMouseButtons() != 0) txSleep(10);
            return true;
        }
    }
    return false;
}

void draw_centered_text(const char* text, int y, int fontSize, COLORREF color)
{
    txSelectFont("Arial", fontSize);
    int textWidth = txGetTextExtentX(text);
    int centerX = (915 - textWidth) / 2;
    
    txSetColor(color);
    txTextOut(centerX, y, text);
}