//+------------------------------------------------------------------+
//|                                                   FBO_Helper.mq5 |
//+------------------------------------------------------------------+
#property copyright "FBO Helper Indicator"
#property link      ""
#property version   "3.00"
#property indicator_chart_window
#property indicator_plots 0
#property indicator_buffers 1
#property indicator_color1 clrNONE 

//+------------------------------------------------------------------+
//| Enumerations                                                      |
//+------------------------------------------------------------------+
enum ENUM_CALC_MODE
{
   CALC_AUTO,      // Auto
   CALC_MANUAL     // Manual
};

enum ENUM_SHADOW_HANDLING
{
   SHADOW_IGNORE,     // Ignore candles with both shadows long
   SHADOW_BOTH,       // Draw lines for both long shadows
   SHADOW_LARGER      // Draw line only for the larger shadow
};

enum ENUM_MERGE_MODE
{
   MERGE_AUTO,     // Auto (based on Stop Loss)
   MERGE_MANUAL    // Manual (custom points)
};

enum ENUM_MERGE_MULTIPLIER
{
   MERGE_1X,       // 1x Stop Loss
   MERGE_HALF,     // 0.5x Stop Loss
   MERGE_THIRD,    // 0.333x Stop Loss (1/3)
   MERGE_QUARTER   // 0.25x Stop Loss
};

enum ENUM_SHADOW_MODE
{
   SHADOW_AUTO,    // Auto (based on Stop Loss)
   SHADOW_MANUAL   // Manual (custom points)
};

enum ENUM_SHADOW_MULTIPLIER
{
   SHADOW_1X,      // 1x Stop Loss
   SHADOW_HALF,    // 0.5x Stop Loss
   SHADOW_THIRD,   // 0.333x Stop Loss (1/3)
   SHADOW_QUARTER  // 0.25x Stop Loss
};
//+------------------------------------------------------------------+
//| Input Parameters - Stop Loss Manual                             |
//+------------------------------------------------------------------+
input group "=== Stop Loss Manual ==="
input int            InpManualStopLoss = 30000;            // Manual StopLoss (Points)
input int            InpManualBreakout = 10000;            // Manual Breakout (Points)

//+------------------------------------------------------------------+
//| Input Parameters - Stop Loss Auto                               |
//+------------------------------------------------------------------+
input group "=== Stop Loss Auto ==="
input ENUM_CALC_MODE InpCalculationMode = CALC_AUTO;       // Calculation Mode
input int            InpATRPeriod = 78;                    // Candle Count Period
input double         InpSLMultiplier = 1.0;                // Multiplier

//+------------------------------------------------------------------+
//| Input Parameters - Highlight Settings                            |
//+------------------------------------------------------------------+
input group "=== Highlight Settings ==="
input int            InpHighlightCandlesBefore = 1;        // Highlight Candles Before
input int            InpHighlightCandlesAfter = 1;         // Highlight Candles After
input color          InpHighlightColor = 10288896;         // Highlight Color

//+------------------------------------------------------------------+
//| Input Parameters - High Line Settings                            |
//+------------------------------------------------------------------+
input group "=== High Line Settings ==="
input color          InpHighLineColor = 5573631;           // High Line Color
input int            InpHighLineWidth = 1;                 // High Line Width
input ENUM_LINE_STYLE InpHighLineStyle = STYLE_SOLID;      // High Line Style

//+------------------------------------------------------------------+
//| Input Parameters - Low Line Settings                             |
//+------------------------------------------------------------------+
input group "=== Low Line Settings ==="
input color          InpLowLineColor = 51976;               // Low Line Color
input int            InpLowLineWidth = 1;                  // Low Line Width
input ENUM_LINE_STYLE InpLowLineStyle = STYLE_SOLID;       // Low Line Style

//+------------------------------------------------------------------+
//| Input Parameters - Line Drawing Settings                         |
//+------------------------------------------------------------------+
input group "=== Line Drawing Settings ==="
input int            InpMagnetCandleRange = 3;             // Magnet Candle Range

//+------------------------------------------------------------------+
//| Input Parameters - Auto Detection (Unmitigated Levels)          |
//+------------------------------------------------------------------+
input group "=== Auto-Detection: Unmitigated Levels ==="
input int            InpLookbackCandles = 200;             // Lookback Candles
input int            InpSwingLeftBars = 1;                 // Swing Left Bars
input int            InpSwingRightBars = 1;                // Swing Right Bars
input bool           InpEnableBOSFilter = true;            // Enable Break of Structure Filter?

//+------------------------------------------------------------------+
//| Input Parameters - Merge Settings                                |
//+------------------------------------------------------------------+
input group "=== Merge Settings ==="
input ENUM_MERGE_MODE InpMergeMode = MERGE_AUTO;           // Merge Mode
input ENUM_MERGE_MULTIPLIER InpMergeMultiplier = MERGE_HALF; // Auto Mode Multiplier
input int            InpMergeProximity = 200;              // Manual Mode Proximity (Points)

//+------------------------------------------------------------------+
//| Input Parameters - Shadow Detection Settings                     |
//+------------------------------------------------------------------+
input group "=== Shadow Detection Settings ==="
input bool           InpEnableShadowDetection = true;      // Enable Long Shadow/PinBar Detection?
input ENUM_SHADOW_MODE InpShadowMode = SHADOW_AUTO;        // Shadow Mode
input ENUM_SHADOW_MULTIPLIER InpShadowMultiplier = SHADOW_HALF; // Auto Mode Multiplier
input int            InpMinShadowPoints = 500;             // Manual Mode Minimum Length (Points)
input ENUM_SHADOW_HANDLING InpLongShadowsHandling = SHADOW_LARGER; // How to handle candles with both shadows long

//+------------------------------------------------------------------+
//| Input Parameters - Fibonacci Settings                            |
//+------------------------------------------------------------------+
input group "=== Fibonacci Settings ==="
input color          InpFiboLineColorBuy = 51976;          // Fibo Line Color (Buy)
input color          InpFiboLineColorSell = 5573631;       // Fibo Line Color (Sell)
input color          InpFiboLineColorRecoveryBuy = 5573631;// Recovery Fibo Color (Buy becomes Sell)
input color          InpFiboLineColorRecoverySell = 51976; // Recovery Fibo Color (Sell becomes Buy)
input int            InpFiboLength = 5;                    // Fibo Length (Candles)
input int            InpFiboFirstOffset = 1;               // First Fibo Offset (Candles)
input int            InpFiboSubsequentOffset = 5;          // Subsequent Fibo Offset (Candles)
input bool           InpUpdateFiboLabelsOnSL = true;       // Update Fibo Labels on SL

//+------------------------------------------------------------------+
//| Input Parameters - Fibo Labels Sell (Initial)                    |
//+------------------------------------------------------------------+
input group "=== Fibo Labels Sell (Initial) ==="
input string         InpFiboSellLevel3Label = "tp";        // Level 3 Label
input string         InpFiboSellLevel1Label = "entry";     // Level 1 Label
input string         InpFiboSellLevel0Label = "sl";        // Level 0 Label
input string         InpFiboSellLevelMinus2Label = "rc.tp"; // Level -2 Label

//+------------------------------------------------------------------+
//| Input Parameters - Fibo Labels Sell (Recovery)                   |
//+------------------------------------------------------------------+
input group "=== Fibo Labels Sell (Recovery) ==="
input string         InpFiboSellLevel1LabelRecov = "rc.entry"; // Level 1 Label (Recovery)
input string         InpFiboSellLevel0LabelRecov = "rc.sl";  // Level 0 Label (Recovery)

//+------------------------------------------------------------------+
//| Input Parameters - Fibo Labels Buy (Initial)                     |
//+------------------------------------------------------------------+
input group "=== Fibo Labels Buy (Initial) ==="
input string         InpFiboBuyLevel3Label = "rc.tp";      // Level 3 Label
input string         InpFiboBuyLevel1Label = "sl";         // Level 1 Label
input string         InpFiboBuyLevel0Label = "entry";      // Level 0 Label
input string         InpFiboBuyLevelMinus2Label = "tp";    // Level -2 Label

//+------------------------------------------------------------------+
//| Input Parameters - Fibo Labels Buy (Recovery)                    |
//+------------------------------------------------------------------+
input group "=== Fibo Labels Buy (Recovery) ==="
input string         InpFiboBuyLevel1LabelRecov = "rc.sl";    // Level 1 Label (Recovery)
input string         InpFiboBuyLevel0LabelRecov = "rc.entry"; // Level 0 Label (Recovery)

//+------------------------------------------------------------------+
//| Input Parameters - Auto Mode Settings                            |
//+------------------------------------------------------------------+
input group "=== Auto Mode Settings ==="
input bool           InpUseSpread = true;                    // Use Spread for Entry/SL Monitoring

//+------------------------------------------------------------------+
//| Input Parameters - Timer Settings                                |
//+------------------------------------------------------------------+
input group "=== Timer Settings ==="
input bool           InpEnableTimer = true;                // Enable Timer
input int            InpTimerDuration = 40;                // Timer Duration (Seconds)
input ENUM_BASE_CORNER InpTimerCorner = CORNER_RIGHT_UPPER;// Timer Anchor Corner
input int            InpTimerX = 68;                       // Timer X Position
input int            InpTimerY = 612;                      // Timer Y Position
input int            InpTimerFontSize = 15;                // Timer Font Size (Icon + Number)
input color          InpTimerColorDefault = 4737096;       // Timer Color (Default)
input color          InpTimerColorArmed = 45055;           // Timer Color (Armed)
input color          InpTimerColorActiveHigh = 5573631;    // Timer Color (Active > 10s)
input color          InpTimerColorActiveLow = 51976;       // Timer Color (Active <= 10s)

//+------------------------------------------------------------------+
//| Input Parameters - Timeframe Warning                             |
//+------------------------------------------------------------------+
input group "=== Timeframe Warning Settings ==="
input bool           InpEnableTimeframeWarning = true;     // Enable Timeframe Warning
input ENUM_TIMEFRAMES InpWarningTimeframe = PERIOD_M5;     // Warning Timeframe
input string         InpWarningText = "WARNING: Timeframe is not M5!"; // Warning Text
input int            InpWarningX = 40;                     // Warning X Position
input int            InpWarningY = 40;                     // Warning Y Position
input int            InpWarningFontSize = 10;              // Warning Font Size
input color          InpWarningColor = 5573631;            // Warning Font Color

//+------------------------------------------------------------------+
//| Input Parameters - Symbol Warning (NEW)                          |
//+------------------------------------------------------------------+
input group "=== Symbol Warning Settings ==="
input bool           InpEnableSymbolWarning = true;        // Enable Symbol Warning
input string         InpWarningSymbol = "US30";            // Warning Symbol (e.g., US30, GDAXI, NAS100)
input string         InpSymbolWarningText = "WARNING: Symbol is not US30!"; // Symbol Warning Text
input int            InpSymbolWarningX = 40;               // Symbol Warning X Position
input int            InpSymbolWarningY = 70;               // Symbol Warning Y Position (below timeframe warning)
input int            InpSymbolWarningFontSize = 10;        // Symbol Warning Font Size
input color          InpSymbolWarningColor = 5573631;      // Symbol Warning Font Color

//+------------------------------------------------------------------+
//| Input Parameters - Motivational Alert Settings (NEW)             |
//+------------------------------------------------------------------+
input group "=== Motivational Alert Settings ==="
input bool           InpEnableAlerts = true;               // Enable Motivational Alerts
input string         InpAlertTextWin = "🔥 BOOM!";         // Win Text (use '|' for newline)
input string         InpAlertTextRecov = "🚀 EPIC RECOVERY!"; // Recovery Win Text (use '|' for newline)
input string         InpAlertTextLoss = "💎 DISCIPLINE MEDAL! Tomorrow is yours."; // Loss Text (use '|' for newline)

//+------------------------------------------------------------------+
//| Input Parameters - UI Panel Settings                             |
//+------------------------------------------------------------------+
input group "=== UI Panel Settings ==="
input ENUM_BASE_CORNER InpPanelCorner = CORNER_RIGHT_UPPER; // Panel Anchor Corner
input int            InpPanelPaddingX = 125;               // Panel Padding X (from corner)
input int            InpPanelPaddingY = 450;               // Panel Padding Y (from corner)
input int            InpButtonWidth = 100;                 // Button Width
input int            InpButtonHeight = 35;                 // Button Height
input int            InpButtonSpacingH = 5;                // Button Horizontal Spacing
input int            InpButtonSpacingV = 5;                // Button Vertical Spacing
input color          InpButtonColorNormal = 4737096;       // Button Color (Normal)
input color          InpButtonColorPressed = 16777215;     // Button Color (Pressed)
input color          InpButtonColorActive = 16766720;      // Button Color (Active)
input color          InpButtonTextColor = 16777215;        // Button Text Color
input int            InpButtonFontSize = 8;                // Button Font Size

//+------------------------------------------------------------------+
//| Input Parameters - Display Text Settings                         |
//+------------------------------------------------------------------+
input group "=== Display Text Settings ==="
input ENUM_BASE_CORNER InpTextCorner = CORNER_RIGHT_UPPER; // Text Anchor Corner
input int            InpTextX = 230;                       // Text X Position
input int            InpTextY = 616;                       // Text Y Position
input color          InpTextColor = 4737096;               // Text Color
input int            InpTextFontSize = 8;                  // Text Font Size

//+------------------------------------------------------------------+
//| Input Parameters - Focus Mode Settings                           |
//+------------------------------------------------------------------+
input group "=== Focus Mode Settings ==="
input int            InpFocusedWidth = 2;                    // Focused Line/Fibo Width (Bold)
input color          InpFocusDimmedColor = clrDarkGray;      // Dimmed Line Color
input int            InpFocusDimmedWidth = 1;                // Dimmed Line Width
input color          InpFocusDimmedBoxColor = C'40,40,40';   // Dimmed Box Color

//+------------------------------------------------------------------+
//| Constants                                                         |
//+------------------------------------------------------------------+
#define MULTIPLIER_FULL     1.0
#define MULTIPLIER_HALF     0.5
#define MULTIPLIER_THIRD    (1.0/3.0)
#define MULTIPLIER_QUARTER  0.25
#define FOCUS_CENTER_DISTANCE_POINTS  100  // Points for fibo center distance check

//+------------------------------------------------------------------+
//| Global Variables                                                  |
//+------------------------------------------------------------------+
// UI Button Names
string g_btnHigh = "FBO_BTN_HIGH";
string g_btnLow = "FBO_BTN_LOW";
string g_btnBuyFibo = "FBO_BTN_BUY_FIBO";
string g_btnSellFibo = "FBO_BTN_SELL_FIBO";
string g_btnStart = "FBO_BTN_START";
string g_btnReset = "FBO_BTN_RESET";
string g_btnAutoDetect = "FBO_BTN_AUTO_DETECT";
string g_btnMerge = "FBO_BTN_MERGE";
string g_btnUndo = "FBO_BTN_UNDO";
string g_btnFocus = "FBO_BTN_FOCUS";
// UI Label Names
string g_lblStopLoss = "FBO_LBL_SL";
string g_lblBreakout = "FBO_LBL_BO";
string g_lblTimer = "FBO_LBL_TIMER";
string g_lblWarning = "FBO_LBL_WARNING";
string g_lblSymbolWarning = "FBO_LBL_SYM_WARNING"; 

// Button States
bool g_isHighActive = false;
bool g_isLowActive = false;
bool g_isUIClick = false; // Flag to distinguish UI clicks from chart clicks

// Auto-Detection State
string g_autoLinePrefix = "FBO_AUTO_"; // Prefix for ALL auto-detected lines (swing + shadow)

// Line Management
string g_linePrefix = "FBO_LINE_"; // Prefix for manually drawn lines
string g_boxPrefix = "FBO_BOX_";
string g_fiboPrefix = "FBO_FIBO_";
int g_lineCounter = 0;
int g_boxCounter = 0;
int g_fiboCounter = 0;
// Line History for Undo
string g_lineHistory[];
int g_lineHistoryCount = 0;

// UNDO System
struct UndoAction
{
   string objectType;    // "LINE" or "FIBO" or "BOX"
   string objectName;    // Object name
   double price1;        // Primary price
   double price2;        // Secondary price (for fibo)
   datetime time1;       // Start time
   datetime time2;       // End time
   color objColor;       // Original color
   int width;            // Line width
   ENUM_LINE_STYLE style;// Line style
   bool isBuy;           // For Fibo tracking (Buy or Sell)
};
UndoAction g_undoStack[10];  // Stack with capacity 10
int g_undoStackSize = 0;     // Current stack size

// FOCUS System
bool g_isFocusActive = false;           // Focus state
string g_focusedLine = "";              // Focused line name
string g_focusedFibo = "";              // Focused fibo name
string g_focusedBox = "";               // Focused highlight box name
int g_focusedLineOriginalWidth = 0;    // Original width of focused line
int g_focusedFiboOriginalLevelWidths[]; // Original level widths of focused fibo
struct ObjectState
{
   string name;
   color  originalColor;
   int    originalWidth;
   ENUM_LINE_STYLE originalStyle;
};
ObjectState g_savedStates[];
int g_savedStatesCount = 0;

// Manual Fibo click tracking
int g_manualFiboCount_Buy = 0;
int g_manualFiboCount_Sell = 0;
string g_manualUsedLines_Buy[];
string g_manualUsedLines_Sell[];

// Calculated Values
int g_calculatedSL = 0;
int g_calculatedBreakout = 0;

// Trade States
enum ENUM_TRADE_STATE
{
   TRADE_STATE_NONE,              // No trade
   TRADE_STATE_BREAKOUT,          // Breakout occurred, waiting for entry
   TRADE_STATE_ACTIVE,            // Trade is active
   TRADE_STATE_RECOVERY          // Recovery trade is active
};
// Fibonacci Tracking Structure
struct FiboInfo
{
   string fiboName;
   string lineName;
   bool isLocked;
   double entryPrice;
   double slPrice;
   double tpPrice;
   int    offsetCandles;
};

// Auto Mode State
bool g_autoModeActive = false;
FiboInfo g_primaryFibo;           // First fibo (broken line)
FiboInfo g_secondaryFibo;         // Second fibo (next line)
bool g_isBuySetup = false;        // true = Buy (Low broken), false = Sell (High broken)
ENUM_TRADE_STATE g_tradeState = TRADE_STATE_NONE;
datetime g_tradeActivationTime = 0;
string g_lastHighlightBoxName = ""; // To track the last highlight box

string g_lastAutoLine1 = "";
string g_lastAutoLine2 = "";

// Timer
bool g_tradeActive = false;       // "timer is running"

// Breakout Tracking
struct BreakoutInfo
{
   string lineName;
   bool breakoutOccurred;
   datetime breakoutTime;
   int breakoutBar;
};
BreakoutInfo g_breakoutHistory[];

// Helper struct for sorting lines
struct LinePrice
{
   string name;
   double price;
};

// OHLC Data Arrays (used for calculations)
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];

//+------------------------------------------------------------------+
//| Forward Declarations                                             |
//+------------------------------------------------------------------+
void ProcessInitialState();
void CheckInitialBreakout();
void ProcessBreakoutState();
void DrawNextSecondaryFibo();
void ProcessActiveState();
void ProcessRecoveryState();
bool IsLineBreakoutProcessed(string lineName);
void ResetManualFiboTracking();
string FindNextNearestLine(string lineType, string &usedLines[]);
void RemoveLineFromHistory(string lineName);
void CheckSymbolWarning();
void SetTimerState(ENUM_TRADE_STATE state);
void FindTwoSequentialLines(string &line1, string &line2);
void ShowAlertMessage(int type);
// Auto-Detection Functions
void DetectUnmitigatedLevels();
bool IsSwingHigh(int bar);
bool IsSwingLow(int bar);
bool IsUnmitigated(double price, bool isHigh, int fromBar);
bool FindNearestPriorSwingLow(int startBar, int maxLookback, double &lowPrice, int &lowBar);   // Helper for BOS
bool FindNearestPriorSwingHigh(int startBar, int maxLookback, double &highPrice, int &highBar); // Helper for BOS
void MergeNearbyLevels();
void CleanAllExceptActiveTrade();
void DrawAutoLine(double price, datetime time, bool isHigh, int barIndex, string type);
// UNDO Functions
void PushUndoAction(string objType, string objName, double p1, double p2, datetime t1, datetime t2, color c, int w, ENUM_LINE_STYLE s, bool isBuy);
void PerformUndo();
// FOCUS Functions
void ToggleFocusMode();
string FindNearestLineToPrice();
void ActivateFocusMode(string nearestLine);
void DeactivateFocusMode();


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set indicator buffers (needed for iHigh etc.)
   SetIndexBuffer(0, ExtOpenBuffer); // We don't actually plot, but need a buffer

   // Create UI Panel (Buttons only)
   CreateUIPanel();
   // Create Timer Label (if enabled)
   if(InpEnableTimer)
   {
      CreateTextLabel(g_lblTimer, "--", InpTimerX, InpTimerY, InpTimerCorner);
      ObjectSetInteger(0, g_lblTimer, OBJPROP_FONTSIZE, InpTimerFontSize);
      ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorDefault); // Default state
   }
   
   // Create SL/Breakout Labels
   CreateTextLabel(g_lblStopLoss, "Stop loss: 0", InpTextX, InpTextY, InpTextCorner);
   CreateTextLabel(g_lblBreakout, "Breakout: 0", InpTextX, InpTextY + 20, InpTextCorner); 

   // Display calculated values (populates the labels created above)
   UpdateCalculatedValues();
   
   // Check timeframe warning
   CheckTimeframeWarning();
   
   // Check symbol warning
   CheckSymbolWarning();
   
   // Enable chart events
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Always delete UI
   DeleteUIPanel();
   
   if(reason == REASON_REMOVE)
   {
      // Full cleanup when indicator is removed
      CleanAllObjects();
   }
   else if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS)
   {
      // On reload, parameter change, or timeframe change:
      // Only clean calculated objects. Preserve manual lines.
      CleanAllBoxes();
      CleanAllFibos();
      ResetAutoMode(); // Reset state machine
      // Clean only auto lines on reload/change
      for(int obj_idx = ObjectsTotal(0, 0, OBJ_HLINE) - 1; obj_idx >= 0; obj_idx--)
      {
         string name = ObjectName(0, obj_idx, 0, OBJ_HLINE);
         if(StringFind(name, g_autoLinePrefix) >= 0)
         {
            ObjectDelete(0, name);
            RemoveLineFromHistory(name);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // Copy OHLC data to global arrays for easier access in functions
   ArraySetAsSeries(ExtOpenBuffer, true);
   ArraySetAsSeries(ExtHighBuffer, true);
   ArraySetAsSeries(ExtLowBuffer, true);
   ArraySetAsSeries(ExtCloseBuffer, true);
   CopyOpen(_Symbol, _Period, 0, rates_total, ExtOpenBuffer);
   CopyHigh(_Symbol, _Period, 0, rates_total, ExtHighBuffer);
   CopyLow(_Symbol, _Period, 0, rates_total, ExtLowBuffer);
   CopyClose(_Symbol, _Period, 0, rates_total, ExtCloseBuffer);

   // Update calculated values
   if(InpCalculationMode == CALC_AUTO)
   {
      if(rates_total < InpATRPeriod + 1) {} // Wait
      else { UpdateCalculatedValues(); }
   }
   else { UpdateCalculatedValues(); }


   // Check for breakouts (Manual mode)
   if(!g_autoModeActive) { CheckBreakouts(); }

   // Auto mode logic
   if(g_autoModeActive) { ProcessAutoMode(); }

   if(g_tradeActive && InpEnableTimer) { UpdateTimer(); }

   // Update Focus Mode dynamically if active
   if(g_isFocusActive)
   {
      string currentNearestLine = FindNearestLineToPrice();
      if(currentNearestLine != "" && currentNearestLine != g_focusedLine)
      {
         // Nearest line has changed, update focus
         DeactivateFocusMode();
         ActivateFocusMode(currentNearestLine);
      }
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // Handle mouse click events
   if(id == CHARTEVENT_CLICK)
   {
      if(g_isUIClick)
      {
         g_isUIClick = false; 
         return;             
      }
      
      int x = (int)lparam;
      int y = (int)dparam;

      if(g_isHighActive || g_isLowActive)
      {
         HandleLineDrawing(x, y);
      }
   }

   // Handle object click events
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      g_isUIClick = true;
      HandleButtonClick(sparam);
   }

   // Handle keyboard events
   if(id == CHARTEVENT_KEYDOWN)
   {
      HandleKeyPress((int)lparam);
   }
}

//+------------------------------------------------------------------+
//| Create UI Panel                                                  |
//+------------------------------------------------------------------+
void CreateUIPanel()
{
   int x = InpPanelPaddingX;
   int y = InpPanelPaddingY;

   int w = InpButtonWidth;
   int h = InpButtonHeight;
   int spacingH = InpButtonSpacingH;
   int spacingV = InpButtonSpacingV;

   int buttonStartY = y;

   int col1X = x;
   int col2X = x + w + spacingH;

   // Row 1: High | S.Fibo
   CreateButton(g_btnHigh, "High", col1X, buttonStartY, w, h, InpPanelCorner);
   CreateButton(g_btnSellFibo, "S.Fibo", col2X, buttonStartY, w, h, InpPanelCorner);

   // Row 2: Low | B.Fibo
   int row2Y = buttonStartY + h + spacingV;
   CreateButton(g_btnLow, "Low", col1X, row2Y, w, h, InpPanelCorner);
   CreateButton(g_btnBuyFibo, "B.Fibo", col2X, row2Y, w, h, InpPanelCorner);

   // Row 3: LHD | MRG
   int row3Y = row2Y + h + spacingV;
   CreateButton(g_btnAutoDetect, "LHD", col1X, row3Y, w, h, InpPanelCorner);
   CreateButton(g_btnMerge, "MRG", col2X, row3Y, w, h, InpPanelCorner);

   // Row 4: Start | Reset
   int row4Y = row3Y + h + spacingV;
   CreateButton(g_btnStart, "Start", col1X, row4Y, w, h, InpPanelCorner);
   CreateButton(g_btnReset, "Reset", col2X, row4Y, w, h, InpPanelCorner);

   // Row 5: Undo | Focus
   int row5Y = row4Y + h + spacingV;
   CreateButton(g_btnUndo, "Undo", col1X, row5Y, w, h, InpPanelCorner);
   CreateButton(g_btnFocus, "Focus", col2X, row5Y, w, h, InpPanelCorner);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Delete UI Panel                                                  |
//+------------------------------------------------------------------+
void DeleteUIPanel()
{
   ObjectDelete(0, g_btnHigh);
   ObjectDelete(0, g_btnLow);
   ObjectDelete(0, g_btnBuyFibo);
   ObjectDelete(0, g_btnSellFibo);
   ObjectDelete(0, g_btnStart);
   ObjectDelete(0, g_btnMerge);
   ObjectDelete(0, g_btnReset);
   ObjectDelete(0, g_btnAutoDetect);
   ObjectDelete(0, g_btnUndo);
   ObjectDelete(0, g_btnFocus);
   ObjectDelete(0, g_lblStopLoss);
   ObjectDelete(0, g_lblBreakout);
   ObjectDelete(0, g_lblTimer);
   ObjectDelete(0, g_lblWarning);
   ObjectDelete(0, g_lblSymbolWarning);
}

//+------------------------------------------------------------------+
//| Create Button                                                    |
//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, int w, int h, ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER)
{
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, InpButtonColorNormal);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpButtonTextColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpButtonFontSize);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Create Text Label                                               |
//+------------------------------------------------------------------+
void CreateTextLabel(string name, string text, int x, int y, ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpTextColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpTextFontSize);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
//| Update Button State                                             |
//+------------------------------------------------------------------+
void UpdateButtonState(string name, bool active)
{
   if(active)
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, InpButtonColorActive);
   else
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, InpButtonColorNormal);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Handle Button Click                                             |
//+------------------------------------------------------------------+
void HandleButtonClick(string clickedObject)
{
   // High button
   if(clickedObject == g_btnHigh)
   {
      g_isHighActive = !g_isHighActive;
      ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, g_isHighActive);
      UpdateButtonState(g_btnHigh, g_isHighActive);

      if(g_isHighActive && g_isLowActive)
      {
         g_isLowActive = false;
         ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, false);
         UpdateButtonState(g_btnLow, false);
      }
   }
   // Low button
   else if(clickedObject == g_btnLow)
   {
      g_isLowActive = !g_isLowActive;
      ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, g_isLowActive);
      UpdateButtonState(g_btnLow, g_isLowActive);

      if(g_isLowActive && g_isHighActive)
      {
         g_isHighActive = false;
         ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, false);
         UpdateButtonState(g_btnHigh, false);
      }
   }
   // Start button
   else if(clickedObject == g_btnStart)
   {
      g_autoModeActive = !g_autoModeActive;
      ObjectSetInteger(0, g_btnStart, OBJPROP_STATE, g_autoModeActive);
      UpdateButtonState(g_btnStart, g_autoModeActive);

      if(g_autoModeActive)
      {
         ResetAutoMode();
         if(g_isHighActive)
         {
            g_isHighActive = false;
            ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, false);
            UpdateButtonState(g_btnHigh, false);
         }
         if(g_isLowActive)
         {
            g_isLowActive = false;
            ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, false);
            UpdateButtonState(g_btnLow, false);
         }
      }
      else
      {
         ResetAutoMode();
      }
   }
   // Buy Fibo button
   else if(clickedObject == g_btnBuyFibo)
   {
      ObjectSetInteger(0, g_btnBuyFibo, OBJPROP_STATE, false);
      if(g_autoModeActive) Alert("This button is disabled in Auto mode");
      else DrawManualFibo(true); // true for Buy
   }
   // Sell Fibo button
   else if(clickedObject == g_btnSellFibo)
   {
      ObjectSetInteger(0, g_btnSellFibo, OBJPROP_STATE, false);
      if(g_autoModeActive) Alert("This button is disabled in Auto mode");
      else DrawManualFibo(false); // false for Sell
   }
   // Reset button
   else if(clickedObject == g_btnReset)
   {
      ObjectSetInteger(0, g_btnReset, OBJPROP_STATE, false);
      ResetIndicator();
   }
   // Auto-Detect button (LHD)
   else if(clickedObject == g_btnAutoDetect)
   {
      ObjectSetInteger(0, g_btnAutoDetect, OBJPROP_STATE, false);
      DetectUnmitigatedLevels(); // Manually trigger detection
   }
   // Merge button (MRG)
   else if(clickedObject == g_btnMerge)
   {
      ObjectSetInteger(0, g_btnMerge, OBJPROP_STATE, false);
      MergeNearbyLevels(); // Merge nearby levels
   }
   // Undo button
   else if(clickedObject == g_btnUndo)
   {
      ObjectSetInteger(0, g_btnUndo, OBJPROP_STATE, false);
      PerformUndo(); // Undo last manual action
   }
   // Focus button
   else if(clickedObject == g_btnFocus)
   {
      ToggleFocusMode(); // Toggle focus mode
   }

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Handle Line Drawing (Magnetic Mode)                             |
//+------------------------------------------------------------------+
void HandleLineDrawing(int x, int y)
{
   int subwindow;
   datetime clickTime;
   double price;
   if(!ChartXYToTimePrice(0, x, y, subwindow, clickTime, price))
      return;

   int centerBar = (int)Bars(_Symbol, _Period, clickTime, TimeCurrent());
   if(centerBar <= 0)
      return;
   centerBar--; 

   int halfRange = InpMagnetCandleRange / 2;
   int startBar = centerBar - halfRange;
   int endBar = centerBar + halfRange;
   if(startBar < 0)
      startBar = 0;
   if(g_isHighActive)
   {
      double highestHigh = -1e100;
      datetime highestTime = 0;
      for(int i = endBar; i >= startBar; i--)
      {
         double high = ExtHighBuffer[i]; // Use buffer
         if(high > highestHigh)
         {
            highestHigh = high;
            highestTime = iTime(_Symbol, _Period, i);
         }
      }
      if(highestHigh > -1e100) DrawHighLine(highestHigh, highestTime);
   }
   else if(g_isLowActive)
   {
      double lowestLow = 1e100;
      datetime lowestTime = 0;

      for(int i = endBar; i >= startBar; i--)
      {
         double low = ExtLowBuffer[i]; // Use buffer
         if(low < lowestLow)
         {
            lowestLow = low;
            lowestTime = iTime(_Symbol, _Period, i);
         }
      }
      if(lowestLow < 1e100) DrawLowLine(lowestLow, lowestTime);
   }
}

//+------------------------------------------------------------------+
//| Draw High Line                                                   |
//+------------------------------------------------------------------+
void DrawHighLine(double price, datetime time)
{
   string lineName = g_linePrefix + "HIGH_" + IntegerToString(g_lineCounter++);
   ObjectCreate(0, lineName, OBJ_HLINE, 0, time, price);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpHighLineColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, InpHighLineWidth);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, InpHighLineStyle);
   ObjectSetInteger(0, lineName, OBJPROP_BACK, false);
   ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, true);

   ArrayResize(g_lineHistory, g_lineHistoryCount + 1);
   g_lineHistory[g_lineHistoryCount++] = lineName;

   // Push to UNDO stack
   PushUndoAction("LINE", lineName, price, 0, time, 0, InpHighLineColor, InpHighLineWidth, InpHighLineStyle, false);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Draw Low Line                                                    |
//+------------------------------------------------------------------+
void DrawLowLine(double price, datetime time)
{
   string lineName = g_linePrefix + "LOW_" + IntegerToString(g_lineCounter++);
   ObjectCreate(0, lineName, OBJ_HLINE, 0, time, price);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpLowLineColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, InpLowLineWidth);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, InpLowLineStyle);
   ObjectSetInteger(0, lineName, OBJPROP_BACK, false);
   ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, true);

   ArrayResize(g_lineHistory, g_lineHistoryCount + 1);
   g_lineHistory[g_lineHistoryCount++] = lineName;

   // Push to UNDO stack
   PushUndoAction("LINE", lineName, price, 0, time, 0, InpLowLineColor, InpLowLineWidth, InpLowLineStyle, false);

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Clean All Lines                                                  |
//+------------------------------------------------------------------+
void CleanAllLines()
{
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      ObjectDelete(0, name);
   }
   
   ArrayResize(g_lineHistory, 0);
   g_lineHistoryCount = 0;
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Clean All Boxes                                                  |
//+------------------------------------------------------------------+
void CleanAllBoxes()
{
   for(int i = ObjectsTotal(0, 0, OBJ_RECTANGLE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      ObjectDelete(0, name); 
   }
   
   ArrayResize(g_breakoutHistory, 0);
   g_lastHighlightBoxName = "";
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Clean All Fibos                                                  |
//+------------------------------------------------------------------+
void CleanAllFibos()
{
   for(int i = ObjectsTotal(0, 0, OBJ_FIBO) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_FIBO);
      ObjectDelete(0, name);
   }
   
   ResetManualFiboTracking();
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Clean All Objects                                                |
//+------------------------------------------------------------------+
void CleanAllObjects()
{
   // This is a full clean (now Super-Clean)
   CleanAllLines();
   CleanAllBoxes();
   CleanAllFibos();
}

//+------------------------------------------------------------------+
//| Reset Auto Mode State                                            |
//+------------------------------------------------------------------+
void ResetAutoMode()
{
   // Reset state machine
   g_tradeState = TRADE_STATE_NONE;
   g_tradeActive = false;
   g_tradeActivationTime = 0;
   SetTimerState(TRADE_STATE_NONE);
   // Reset fibo tracking
   g_primaryFibo.fiboName = "";
   g_primaryFibo.lineName = "";
   g_primaryFibo.isLocked = false;
   g_primaryFibo.entryPrice = 0;
   g_primaryFibo.slPrice = 0;
   g_primaryFibo.tpPrice = 0;
   g_primaryFibo.offsetCandles = 0;

   g_secondaryFibo.fiboName = "";
   g_secondaryFibo.lineName = "";
   g_secondaryFibo.isLocked = false;
   g_secondaryFibo.entryPrice = 0;
   g_secondaryFibo.slPrice = 0;
   g_secondaryFibo.tpPrice = 0;
   g_secondaryFibo.offsetCandles = 0;

   g_isBuySetup = false;
   g_lastAutoLine1 = "";
   g_lastAutoLine2 = "";
}

//+------------------------------------------------------------------+
//| Delete ALL Chart Objects (Complete Reset)                        |
//+------------------------------------------------------------------+
void DeleteAllChartObjects()
{
   // Delete ALL Horizontal Lines
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      ObjectDelete(0, name);
   }

   // Delete ALL Trend Lines
   for(int i = ObjectsTotal(0, 0, OBJ_TREND) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_TREND);
      ObjectDelete(0, name);
   }

   // Delete ALL Vertical Lines
   for(int i = ObjectsTotal(0, 0, OBJ_VLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_VLINE);
      ObjectDelete(0, name);
   }

   // Delete ALL Rectangles/Boxes
   for(int i = ObjectsTotal(0, 0, OBJ_RECTANGLE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      ObjectDelete(0, name);
   }

   // Delete ALL Fibonacci Retracements
   for(int i = ObjectsTotal(0, 0, OBJ_FIBO) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_FIBO);
      ObjectDelete(0, name);
   }

   // Reset line history
   ArrayResize(g_lineHistory, 0);
   g_lineHistoryCount = 0;

   // Reset manual fibo tracking
   ResetManualFiboTracking();
}

//+------------------------------------------------------------------+
//| Clean All Objects Except Active Trade                            |
//+------------------------------------------------------------------+
void CleanAllExceptActiveTrade()
{
   // Delete all Horizontal Lines EXCEPT the primary fibo line
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      if(name != g_primaryFibo.lineName)
         ObjectDelete(0, name);
   }

   // Delete all Fibonacci Retracements EXCEPT the primary fibo
   for(int i = ObjectsTotal(0, 0, OBJ_FIBO) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_FIBO);
      if(name != g_primaryFibo.fiboName)
         ObjectDelete(0, name);
   }

   // Delete all Rectangles/Boxes EXCEPT the current highlight
   for(int i = ObjectsTotal(0, 0, OBJ_RECTANGLE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      if(name != g_lastHighlightBoxName)
         ObjectDelete(0, name);
   }

   // Delete ALL Trend Lines
   for(int i = ObjectsTotal(0, 0, OBJ_TREND) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_TREND);
      ObjectDelete(0, name);
   }

   // Delete ALL Vertical Lines
   for(int i = ObjectsTotal(0, 0, OBJ_VLINE) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, OBJ_VLINE);
      ObjectDelete(0, name);
   }

   // Clear line history except for the primary fibo line
   int newSize = 0;
   if(g_primaryFibo.lineName != "")
   {
      // Keep only the primary line in history
      g_lineHistory[0] = g_primaryFibo.lineName;
      newSize = 1;
   }
   ArrayResize(g_lineHistory, newSize);
   g_lineHistoryCount = newSize;
}

//+------------------------------------------------------------------+
//| Reset Entire Indicator                                           |
//+------------------------------------------------------------------+
void ResetIndicator()
{
   // Delete ALL objects on chart (not just FBO_* ones)
   DeleteAllChartObjects();

   // Reset auto mode (resets state, timer, fibo tracking, line memory)
   ResetAutoMode();

   // Reset button states
   g_isHighActive = false;
   g_isLowActive = false;
   g_autoModeActive = false;

   ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, false);
   UpdateButtonState(g_btnHigh, false);

   ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, false);
   UpdateButtonState(g_btnLow, false);

   ObjectSetInteger(0, g_btnStart, OBJPROP_STATE, false);
   UpdateButtonState(g_btnStart, false);

   ObjectSetInteger(0, g_btnReset, OBJPROP_BGCOLOR, InpButtonColorNormal);

   // Reset counters
   g_lineCounter = 0;
   g_boxCounter = 0;
   g_fiboCounter = 0;

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update Calculated Values                                         |
//+------------------------------------------------------------------+
void UpdateCalculatedValues()
{
   if(InpCalculationMode == CALC_MANUAL)
   {
      g_calculatedSL = InpManualStopLoss;
      g_calculatedBreakout = InpManualBreakout;
   }
   else // CALC_AUTO - Only Candle logic remains
   {
      double avgSize = 0;
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

      // Only Candle calculation is left
      double totalSize = 0;
      int bars = InpATRPeriod; // Use the same input parameter

      int barsAvailable = ArraySize(ExtHighBuffer); // Use size of copied buffer
      int barsToScan = MathMin(bars, barsAvailable - 1);
      if(barsToScan <= 0)
      {
         avgSize = 0; // Not enough data
      }
      else
      {
         for(int i = 1; i <= barsToScan; i++)
         {
            double high = ExtHighBuffer[i]; // Use buffer
            double low = ExtLowBuffer[i];   // Use buffer
            totalSize += (high - low);
         }
         avgSize = totalSize / barsToScan;
      }

      g_calculatedSL = (int)MathRound((avgSize / point) * InpSLMultiplier);
      g_calculatedBreakout = (int)MathRound(g_calculatedSL / 3.0);
   }

   ObjectSetString(0, g_lblStopLoss, OBJPROP_TEXT, "Stop loss: " + IntegerToString(g_calculatedSL));
   ObjectSetString(0, g_lblBreakout, OBJPROP_TEXT, "Breakout: " + IntegerToString(g_calculatedBreakout));
}

//+------------------------------------------------------------------+
//| Check Timeframe Warning                                          |
//+------------------------------------------------------------------+
void CheckTimeframeWarning()
{
   if(!InpEnableTimeframeWarning)
   {
      ObjectDelete(0, g_lblWarning); // Delete if disabled
      return;
   }

   if(_Period != InpWarningTimeframe)
   {
      if(ObjectFind(0, g_lblWarning) < 0)
      {
         CreateTextLabel(g_lblWarning, InpWarningText, InpWarningX, InpWarningY);
      }
      ObjectSetInteger(0, g_lblWarning, OBJPROP_COLOR, InpWarningColor);
      ObjectSetInteger(0, g_lblWarning, OBJPROP_FONTSIZE, InpWarningFontSize);
   }
   else
   {
      ObjectDelete(0, g_lblWarning);
   }
}

//+------------------------------------------------------------------+
//| Check Symbol Warning                                             |
//+------------------------------------------------------------------+
void CheckSymbolWarning()
{
   if(!InpEnableSymbolWarning)
   {
      ObjectDelete(0, g_lblSymbolWarning); // Delete if disabled
      return;
   }

   if(StringFind(_Symbol, InpWarningSymbol, 0) == -1)
   {
      if(ObjectFind(0, g_lblSymbolWarning) < 0)
      {
         CreateTextLabel(g_lblSymbolWarning, InpSymbolWarningText, InpSymbolWarningX, InpSymbolWarningY);
      }
      ObjectSetInteger(0, g_lblSymbolWarning, OBJPROP_COLOR, InpSymbolWarningColor);
      ObjectSetInteger(0, g_lblSymbolWarning, OBJPROP_FONTSIZE, InpSymbolWarningFontSize);
   }
   else
   {
      ObjectDelete(0, g_lblSymbolWarning);
   }
}

//+------------------------------------------------------------------+
//| Check Breakouts (For Manual Mode)                                |
//+------------------------------------------------------------------+
void CheckBreakouts()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int breakoutPoints = g_calculatedBreakout;
   for(int i = 0; i < g_lineHistoryCount; i++)
   {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0)
         continue;
      if(IsLineBreakoutProcessed(lineName))
      {
         continue;
      }

      double linePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
      // Determine if high/low based on prefix, more robust than StringFind
      bool isHighLine = (StringSubstr(lineName, StringLen(g_linePrefix), 4) == "HIGH" || StringSubstr(lineName, StringLen(g_autoLinePrefix), 4) == "HIGH" || StringSubstr(lineName, StringLen(g_autoLinePrefix), 10) == "SHADOW_HIGH");
      bool isLowLine = (StringSubstr(lineName, StringLen(g_linePrefix), 3) == "LOW" || StringSubstr(lineName, StringLen(g_autoLinePrefix), 3) == "LOW" || StringSubstr(lineName, StringLen(g_autoLinePrefix), 9) == "SHADOW_LOW");

      if(isHighLine)
      {
         if(bid >= linePrice + (breakoutPoints * point))
         {
            CreateBreakoutHighlight(lineName, linePrice, true);
         }
      }
      else if(isLowLine)
      {
         if(bid <= linePrice - (breakoutPoints * point))
         {
            CreateBreakoutHighlight(lineName, linePrice, false);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Create Breakout Highlight Box                                   |
//+------------------------------------------------------------------+
void CreateBreakoutHighlight(string lineName, double linePrice, bool isHigh)
{
   int currentBar = 0;
   datetime currentTime = iTime(_Symbol, _Period, currentBar);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int breakoutPoints = g_calculatedBreakout;

   double priceTop, priceBottom;
   if(isHigh)
   {
      priceBottom = linePrice;
      priceTop = linePrice + (breakoutPoints * point);
   }
   else
   {
      priceTop = linePrice;
      priceBottom = linePrice - (breakoutPoints * point);
   }

   datetime timeStart = iTime(_Symbol, _Period, currentBar + InpHighlightCandlesBefore);
   datetime timeEnd = iTime(_Symbol, _Period, 0) + (PeriodSeconds() * InpHighlightCandlesAfter);
   if(timeEnd <= timeStart)
   {
      timeEnd = timeStart + PeriodSeconds();
   }

   string boxName = g_boxPrefix + IntegerToString(g_boxCounter++);

   ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, timeStart, priceTop, timeEnd, priceBottom);
   ObjectSetInteger(0, boxName, OBJPROP_COLOR, InpHighlightColor);
   ObjectSetInteger(0, boxName, OBJPROP_FILL, true);
   ObjectSetInteger(0, boxName, OBJPROP_BACK, true);
   ObjectSetInteger(0, boxName, OBJPROP_SELECTABLE, false);

   int size = ArraySize(g_breakoutHistory);
   ArrayResize(g_breakoutHistory, size + 1);
   g_breakoutHistory[size].lineName = lineName;
   g_breakoutHistory[size].breakoutOccurred = true;
   g_breakoutHistory[size].breakoutTime = currentTime;
   g_breakoutHistory[size].breakoutBar = currentBar;
   
   g_lastHighlightBoxName = boxName; 

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Process Auto Mode                                                |
//+------------------------------------------------------------------+
void ProcessAutoMode()
{
   if(!g_autoModeActive)
      return;
   switch(g_tradeState)
   {
      case TRADE_STATE_NONE:
         ProcessInitialState();
         break;
      case TRADE_STATE_BREAKOUT:
         ProcessBreakoutState();
         break;
      case TRADE_STATE_ACTIVE:
         ProcessActiveState();
         break;
      case TRADE_STATE_RECOVERY:
         ProcessRecoveryState();
         break;
   }
}

//+------------------------------------------------------------------+
//| Draw Manual Fibo                                                 |
//+------------------------------------------------------------------+
void DrawManualFibo(bool isBuy)
{
   string targetLineType = isBuy ? "LOW" : "HIGH";
   int clickCount = isBuy ? g_manualFiboCount_Buy : g_manualFiboCount_Sell;
   string lineName = "";
   
   if(isBuy) lineName = FindNextNearestLine(targetLineType, g_manualUsedLines_Buy);
   else      lineName = FindNextNearestLine(targetLineType, g_manualUsedLines_Sell);
      
   if(lineName == "")
   {
      Alert("No more unused " + targetLineType + " lines found!");
      // Reset count and used lines if no lines found on first click
      if(clickCount == 0) return; 
      if(isBuy) { g_manualFiboCount_Buy = 0; ArrayResize(g_manualUsedLines_Buy, 0); }
      else      { g_manualFiboCount_Sell = 0; ArrayResize(g_manualUsedLines_Sell, 0); }
      return;
   }

   // Add to used lines
   if(isBuy) { ArrayResize(g_manualUsedLines_Buy, ArraySize(g_manualUsedLines_Buy) + 1); g_manualUsedLines_Buy[ArraySize(g_manualUsedLines_Buy)-1] = lineName; }
   else      { ArrayResize(g_manualUsedLines_Sell, ArraySize(g_manualUsedLines_Sell) + 1); g_manualUsedLines_Sell[ArraySize(g_manualUsedLines_Sell)-1] = lineName; }

   int offset = InpFiboFirstOffset + (clickCount * InpFiboSubsequentOffset);
   double linePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
   DrawFibonacci(linePrice, isBuy, false, offset, true); // true = manual fibo

   if(isBuy) g_manualFiboCount_Buy++;
   else      g_manualFiboCount_Sell++;
}

//+------------------------------------------------------------------+
//| Draw Fibonacci                                                   |
//+------------------------------------------------------------------+
string DrawFibonacci(double linePrice, bool isBuy, bool isRecovery, int offsetCandles, bool isManual = false)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int slPoints = g_calculatedSL;
   if(slPoints <= 0) return ""; // Avoid drawing if SL is not calculated yet

   double level0, level1, level3, levelMinus2;

   if(isBuy) { // BUY FIBO
      level0 = linePrice - (slPoints / 2.0) * point;      // sl
      level1 = linePrice + (slPoints / 2.0) * point;      // entry
      level3 = level1 + (slPoints * 2.0) * point;      // tp
      levelMinus2 = level0 - (slPoints * 2.0) * point;   // rc.tp
   } else { // SELL FIBO
      level0 = linePrice - (slPoints / 2.0) * point;      // entry
      level1 = linePrice + (slPoints / 2.0) * point;      // sl
      level3 = level1 + (slPoints * 2.0) * point;      // rc.tp
      levelMinus2 = level0 - (slPoints * 2.0) * point;   // tp
   }

   string fiboName = g_fiboPrefix + (isBuy ? "BUY_" : "SELL_") + IntegerToString(g_fiboCounter++);
   datetime now = iTime(_Symbol, _Period, 0);
   long periodSeconds = PeriodSeconds();
   datetime timeStart = (datetime)(now + (offsetCandles * periodSeconds));
   datetime timeEnd = (datetime)(timeStart + (InpFiboLength * periodSeconds));
 
   ObjectCreate(0, fiboName, OBJ_FIBO, 0, timeStart, level0, timeEnd, level1);
   color fiboColor = isBuy ? InpFiboLineColorBuy : InpFiboLineColorSell; 
   ObjectSetInteger(0, fiboName, OBJPROP_COLOR, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_BACK, false);
   ObjectSetInteger(0, fiboName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, fiboName, OBJPROP_RAY_RIGHT, false); 
   ObjectSetInteger(0, fiboName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELS, 4);
   
   // Level 0
   ObjectSetDouble(0, fiboName, OBJPROP_LEVELVALUE, 0, 0.0);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 0, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELWIDTH, 0, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELSTYLE, 0, STYLE_SOLID);
   if(isBuy) ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 0, isRecovery ? InpFiboBuyLevel0LabelRecov : InpFiboBuyLevel0Label);
   else      ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 0, isRecovery ? InpFiboSellLevel0LabelRecov : InpFiboSellLevel0Label);

   // Level 1
   ObjectSetDouble(0, fiboName, OBJPROP_LEVELVALUE, 1, 1.0);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 1, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELWIDTH, 1, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELSTYLE, 1, STYLE_SOLID);
   if(isBuy) ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 1, isRecovery ? InpFiboBuyLevel1LabelRecov : InpFiboBuyLevel1Label);
   else      ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 1, isRecovery ? InpFiboSellLevel1LabelRecov : InpFiboSellLevel1Label);

   // Level 3
   ObjectSetDouble(0, fiboName, OBJPROP_LEVELVALUE, 2, 3.0);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 2, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELWIDTH, 2, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELSTYLE, 2, STYLE_SOLID);
   ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 2, isBuy ? InpFiboBuyLevel3Label : InpFiboSellLevel3Label);
   
   // Level -2
   ObjectSetDouble(0, fiboName, OBJPROP_LEVELVALUE, 3, -2.0);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 3, fiboColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELWIDTH, 3, 1);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELSTYLE, 3, STYLE_SOLID);
   ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 3, isBuy ? InpFiboBuyLevelMinus2Label : InpFiboSellLevelMinus2Label);

   // Push to UNDO stack if manual
   if(isManual)
   {
      PushUndoAction("FIBO", fiboName, level0, level1, timeStart, timeEnd, fiboColor, 1, STYLE_DOT, isBuy);
   }

   ChartRedraw();
   return fiboName;
}

//+------------------------------------------------------------------+
//| Find Two Sequential Lines by Price                               |
//+------------------------------------------------------------------+
void FindTwoSequentialLines(string &line1, string &line2)
{
   line1 = "";
   line2 = "";
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double distHigh = 1e100, distLow = 1e100;
   string closestHigh = "", closestLow = "";

   for(int i = 0; i < g_lineHistoryCount; i++) {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0) continue;
      double linePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
      double distance = MathAbs(currentPrice - linePrice);
      // More robust check using prefixes
      bool isAnyHigh = StringFind(lineName, "_HIGH_") > 0 || StringFind(lineName, "_SHADOW_HIGH_") > 0;
      bool isAnyLow = StringFind(lineName, "_LOW_") > 0 || StringFind(lineName, "_SHADOW_LOW_") > 0;
      if(isAnyHigh) { if(distance < distHigh) { distHigh = distance; closestHigh = lineName; } } 
      else if(isAnyLow) { if(distance < distLow) { distLow = distance; closestLow = lineName; } }
   }

   if(closestHigh == "" && closestLow == "") return;
   bool useHigh = (distHigh < distLow);
   string primaryType = useHigh ? "HIGH" : "LOW"; // Primary type for sorting
   g_isBuySetup = !useHigh; // High lines = Sell, Low lines = Buy

   LinePrice lines[];
   int count = 0;
   for(int i = 0; i < g_lineHistoryCount; i++) {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0) continue;
      // Check if line matches the determined primary type (HIGH or LOW, including SHADOW)
      if((useHigh && (StringFind(lineName, "_HIGH_")>0 || StringFind(lineName, "_SHADOW_HIGH_")>0)) ||
         (!useHigh && (StringFind(lineName, "_LOW_")>0 || StringFind(lineName, "_SHADOW_LOW_")>0)))
      {
         ArrayResize(lines, count + 1);
         lines[count].name = lineName;
         lines[count].price = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
         count++;
      }
   }

   if(count == 0) return;

   // Sort: Highs Ascending, Lows Descending
   for(int i = 0; i < count - 1; i++) {
      for(int j = 0; j < count - i - 1; j++) {
         bool shouldSwap = (useHigh && lines[j].price > lines[j+1].price) || 
                           (!useHigh && lines[j].price < lines[j+1].price);
         if(shouldSwap) { LinePrice temp = lines[j]; lines[j] = lines[j+1]; lines[j+1] = temp; }
      }
   }

   if(count > 0) line1 = lines[0].name;
   if(count > 1) line2 = lines[1].name;
}


//+------------------------------------------------------------------+
//| Delete Opposite Lines and Fibos                                 |
//+------------------------------------------------------------------+
void DeleteOppositeType(bool isHighLineBreak)
{
   string typeToDelete = isHighLineBreak ? "LOW" : "HIGH";
   string shadowTypeToDelete = isHighLineBreak ? "SHADOW_LOW" : "SHADOW_HIGH";
   string fiboTypeToDelete = isHighLineBreak ? "FBO_FIBO_BUY" : "FBO_FIBO_SELL";

   for(int i = g_lineHistoryCount - 1; i >= 0; i--) {
      string lineName = g_lineHistory[i];
      if(StringFind(lineName, "_" + typeToDelete + "_") > 0 || StringFind(lineName, "_" + shadowTypeToDelete + "_") > 0) {
         ObjectDelete(0, lineName);
         RemoveLineFromHistory(lineName); 
      }
   }

   for(int i = ObjectsTotal(0, 0, OBJ_FIBO) - 1; i >= 0; i--) {
      string name = ObjectName(0, i, 0, OBJ_FIBO);
      if(StringFind(name, fiboTypeToDelete) >= 0) ObjectDelete(0, name);
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Process Initial State - Draw 2 Fibos on Sequential Lines         |
//+------------------------------------------------------------------+
void ProcessInitialState()
{
   string line1, line2;
   FindTwoSequentialLines(line1, line2); 
   if(line1 == "") return;

   if(line1 != g_lastAutoLine1 || line2 != g_lastAutoLine2) {
      if(g_primaryFibo.fiboName != "") ObjectDelete(0, g_primaryFibo.fiboName);
      if(g_secondaryFibo.fiboName != "") ObjectDelete(0, g_secondaryFibo.fiboName);

      double line1Price = ObjectGetDouble(0, line1, OBJPROP_PRICE);
      g_primaryFibo.offsetCandles = InpFiboFirstOffset;
      g_primaryFibo.fiboName = DrawFibonacci(line1Price, g_isBuySetup, false, g_primaryFibo.offsetCandles);
      g_primaryFibo.lineName = line1;
      g_primaryFibo.isLocked = false;
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int slPoints = g_calculatedSL;
      if(g_isBuySetup) { // Buy
         g_primaryFibo.slPrice = line1Price - (slPoints / 2.0) * point;
         g_primaryFibo.entryPrice = line1Price + (slPoints / 2.0) * point;
         g_primaryFibo.tpPrice = g_primaryFibo.entryPrice + (slPoints * 2.0) * point;
      } else { // Sell
         g_primaryFibo.entryPrice = line1Price - (slPoints / 2.0) * point;
         g_primaryFibo.slPrice = line1Price + (slPoints / 2.0) * point;
         g_primaryFibo.tpPrice = g_primaryFibo.entryPrice - (slPoints * 2.0) * point;
      }

      if(line2 != "") {
         double line2Price = ObjectGetDouble(0, line2, OBJPROP_PRICE);
         int offset = InpFiboFirstOffset + InpFiboSubsequentOffset;
         g_secondaryFibo.offsetCandles = offset;
         g_secondaryFibo.fiboName = DrawFibonacci(line2Price, g_isBuySetup, false, g_secondaryFibo.offsetCandles);
         g_secondaryFibo.lineName = line2;
         g_secondaryFibo.isLocked = false;
         if(g_isBuySetup) { // Buy
            g_secondaryFibo.slPrice = line2Price - (slPoints / 2.0) * point;
            g_secondaryFibo.entryPrice = line2Price + (slPoints / 2.0) * point;
            g_secondaryFibo.tpPrice = g_secondaryFibo.entryPrice + (slPoints * 2.0) * point;
         } else { // Sell
            g_secondaryFibo.entryPrice = line2Price - (slPoints / 2.0) * point;
            g_secondaryFibo.slPrice = line2Price + (slPoints / 2.0) * point;
            g_secondaryFibo.tpPrice = g_secondaryFibo.entryPrice - (slPoints * 2.0) * point;
         }
      } else {
         g_secondaryFibo.fiboName = ""; g_secondaryFibo.lineName = ""; g_secondaryFibo.offsetCandles = 0;
      }
      g_lastAutoLine1 = line1; g_lastAutoLine2 = line2;
   }
   CheckInitialBreakout();
}

//+------------------------------------------------------------------+
//| Check for Breakout in Initial State                             |
//+------------------------------------------------------------------+
void CheckInitialBreakout()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int breakoutPoints = g_calculatedBreakout;
   
   // Check primary line
   if(g_primaryFibo.lineName != "" && ObjectFind(0, g_primaryFibo.lineName) >= 0) {
      if(!IsLineBreakoutProcessed(g_primaryFibo.lineName)) {
         double linePrice = ObjectGetDouble(0, g_primaryFibo.lineName, OBJPROP_PRICE);
         // Use g_isBuySetup which is set by FindTwoSequentialLines
         bool breakoutOccurred = (g_isBuySetup && bid <= linePrice - (breakoutPoints * point)) || 
                                 (!g_isBuySetup && bid >= linePrice + (breakoutPoints * point));
         if(breakoutOccurred) {
            CreateBreakoutHighlight(g_primaryFibo.lineName, linePrice, !g_isBuySetup); // isHigh = !g_isBuySetup
            DeleteOppositeType(!g_isBuySetup); 
            g_tradeState = TRADE_STATE_BREAKOUT;
            SetTimerState(g_tradeState); 
            g_primaryFibo.isLocked = true;
            return; // Primary broke, stop checking secondary
         }
      }
   }

   // Check secondary line ONLY if primary didn't break
   if(g_secondaryFibo.lineName != "" && ObjectFind(0, g_secondaryFibo.lineName) >= 0) {
      if(!IsLineBreakoutProcessed(g_secondaryFibo.lineName)) {
         double linePrice = ObjectGetDouble(0, g_secondaryFibo.lineName, OBJPROP_PRICE);
         bool breakoutOccurred = (g_isBuySetup && bid <= linePrice - (breakoutPoints * point)) || 
                                 (!g_isBuySetup && bid >= linePrice + (breakoutPoints * point));
         if(breakoutOccurred) {
            CreateBreakoutHighlight(g_secondaryFibo.lineName, linePrice, !g_isBuySetup);
            // Delete the old primary objects
            ObjectDelete(0, g_primaryFibo.fiboName);
            if(g_primaryFibo.lineName != "" && ObjectFind(0, g_primaryFibo.lineName) >= 0) {
               ObjectDelete(0, g_primaryFibo.lineName);
               RemoveLineFromHistory(g_primaryFibo.lineName);
            }
            DeleteOppositeType(!g_isBuySetup); // Keep the type of the broken line
            // Promote secondary to primary
            g_primaryFibo = g_secondaryFibo;
            g_secondaryFibo.fiboName = ""; g_secondaryFibo.lineName = ""; g_secondaryFibo.offsetCandles = 0;
            g_tradeState = TRADE_STATE_BREAKOUT;
            SetTimerState(g_tradeState); 
            g_primaryFibo.isLocked = true;
            DrawNextSecondaryFibo(); // Find the next one
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Process Breakout State - Wait for Entry or Next Breakout        |
//+------------------------------------------------------------------+
void ProcessBreakoutState()
{
   if(g_primaryFibo.fiboName == "") return;

   double currentPrice = InpUseSpread ? (g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID)) 
                                      : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   bool entryReached = (g_isBuySetup && currentPrice >= g_primaryFibo.entryPrice) || 
                       (!g_isBuySetup && currentPrice <= g_primaryFibo.entryPrice);

   if(entryReached) {
      // Delete secondary if exists
      if(g_secondaryFibo.fiboName != "" && ObjectFind(0, g_secondaryFibo.fiboName) >= 0) ObjectDelete(0, g_secondaryFibo.fiboName);
      if(g_secondaryFibo.lineName != "" && ObjectFind(0, g_secondaryFibo.lineName) >= 0) { ObjectDelete(0, g_secondaryFibo.lineName); RemoveLineFromHistory(g_secondaryFibo.lineName); }
      g_secondaryFibo.fiboName = ""; g_secondaryFibo.lineName = ""; g_secondaryFibo.offsetCandles = 0;

      g_tradeState = TRADE_STATE_ACTIVE;
      SetTimerState(g_tradeState);
      CleanAllExceptActiveTrade();
      g_tradeActivationTime = TimeCurrent();
      g_tradeActive = true; 
      return;
   }

   // Check for secondary line breakout
   if(g_secondaryFibo.lineName != "" && ObjectFind(0, g_secondaryFibo.lineName) >= 0) {
      if(!IsLineBreakoutProcessed(g_secondaryFibo.lineName)) {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         int breakoutPoints = g_calculatedBreakout;
         double linePrice = ObjectGetDouble(0, g_secondaryFibo.lineName, OBJPROP_PRICE);
         bool breakoutOccurred = (g_isBuySetup && bid <= linePrice - (breakoutPoints * point)) || 
                                 (!g_isBuySetup && bid >= linePrice + (breakoutPoints * point));
         if(breakoutOccurred) {
            if(g_lastHighlightBoxName != "") ObjectDelete(0, g_lastHighlightBoxName); // Delete previous highlight
            CreateBreakoutHighlight(g_secondaryFibo.lineName, linePrice, !g_isBuySetup);
            ObjectDelete(0, g_primaryFibo.fiboName);
            if(g_primaryFibo.lineName != "" && ObjectFind(0, g_primaryFibo.lineName) >= 0) { ObjectDelete(0, g_primaryFibo.lineName); RemoveLineFromHistory(g_primaryFibo.lineName); }
            
            g_primaryFibo = g_secondaryFibo; // Promote secondary
            g_secondaryFibo.fiboName = ""; g_secondaryFibo.lineName = ""; g_secondaryFibo.offsetCandles = 0;
            g_primaryFibo.isLocked = true;
            SetTimerState(g_tradeState); // Timer stays in breakout (armed) state
            DrawNextSecondaryFibo(); // Find the next one
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Draw Next Secondary Fibo                                        |
//+------------------------------------------------------------------+
void DrawNextSecondaryFibo()
{
   if(g_primaryFibo.lineName == "" || ObjectFind(0, g_primaryFibo.lineName) < 0) return; // Need a valid primary line

   string lineType = g_isBuySetup ? "LOW" : "HIGH"; 
   double primaryLinePrice = ObjectGetDouble(0, g_primaryFibo.lineName, OBJPROP_PRICE);
   string nextLine = "";
   double minDistance = 1e100;
   
   for(int i = 0; i < g_lineHistoryCount; i++) {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0 || lineName == g_primaryFibo.lineName || IsLineBreakoutProcessed(lineName)) continue;
      // Check if line matches the current setup type (HIGH or LOW, including SHADOW)
      if(!((g_isBuySetup && (StringFind(lineName, "_LOW_")>0 || StringFind(lineName, "_SHADOW_LOW_")>0)) ||
           (!g_isBuySetup && (StringFind(lineName, "_HIGH_")>0 || StringFind(lineName, "_SHADOW_HIGH_")>0)))) continue;

      double linePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
      bool correctDirection = (g_isBuySetup && linePrice < primaryLinePrice) || (!g_isBuySetup && linePrice > primaryLinePrice); 
      
      if(correctDirection) {
         double distance = MathAbs(linePrice - primaryLinePrice);
         if(distance < minDistance) { minDistance = distance; nextLine = lineName; }
      }
   }

   if(nextLine != "") {
      double linePrice = ObjectGetDouble(0, nextLine, OBJPROP_PRICE);
      int offset = g_primaryFibo.offsetCandles + InpFiboSubsequentOffset;
      g_secondaryFibo.offsetCandles = offset;
      g_secondaryFibo.fiboName = DrawFibonacci(linePrice, g_isBuySetup, false, g_secondaryFibo.offsetCandles);
      g_secondaryFibo.lineName = nextLine;
      g_secondaryFibo.isLocked = false;
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int slPoints = g_calculatedSL;
      if(g_isBuySetup) { // Buy
         g_secondaryFibo.slPrice = linePrice - (slPoints / 2.0) * point;
         g_secondaryFibo.entryPrice = linePrice + (slPoints / 2.0) * point;
         g_secondaryFibo.tpPrice = g_secondaryFibo.entryPrice + (slPoints * 2.0) * point;
      } else { // Sell
         g_secondaryFibo.entryPrice = linePrice - (slPoints / 2.0) * point;
         g_secondaryFibo.slPrice = linePrice + (slPoints / 2.0) * point;
         g_secondaryFibo.tpPrice = g_secondaryFibo.entryPrice - (slPoints * 2.0) * point;
      }
   }
}

//+------------------------------------------------------------------+
//| Process Active State - Monitor SL/TP                            |
//+------------------------------------------------------------------+
void ProcessActiveState()
{
   if(!g_tradeActive) return; 

   double slCheckPrice = InpUseSpread ? (g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID)) 
                                      : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   bool slHit = (g_isBuySetup && slCheckPrice <= g_primaryFibo.slPrice) || 
                (!g_isBuySetup && slCheckPrice >= g_primaryFibo.slPrice); 

   if(slHit) {
      g_tradeState = TRADE_STATE_RECOVERY;
      SetTimerState(g_tradeState); 
      if(InpUpdateFiboLabelsOnSL && g_primaryFibo.fiboName != "") UpdateFiboLabelsToRecovery(g_primaryFibo.fiboName, g_isBuySetup);
      if(InpEnableTimer) g_tradeActivationTime = TimeCurrent(); // Reset timer
      return; 
   }

   double tpCheckPrice = InpUseSpread ? (g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK)) 
                                      : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   bool tpHit = (g_isBuySetup && tpCheckPrice >= g_primaryFibo.tpPrice) || 
                (!g_isBuySetup && tpCheckPrice <= g_primaryFibo.tpPrice); 

   if(tpHit) {
      g_tradeActive = false; 
      g_tradeState = TRADE_STATE_NONE; 
      SetTimerState(g_tradeState); 
      ShowAlertMessage(1); 
   }
}

//+------------------------------------------------------------------+
//| Process Recovery State - Monitor Recovery SL/TP                 |
//+------------------------------------------------------------------+
void ProcessRecoveryState()
{
   if(!g_tradeActive) return; 

   double recoverySL = g_primaryFibo.entryPrice; 
   double slCheckPrice = InpUseSpread ? (g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK)) 
                                      : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   bool slHit = (g_isBuySetup && slCheckPrice >= recoverySL) || 
                (!g_isBuySetup && slCheckPrice <= recoverySL); 
   if(slHit) {
      g_tradeActive = false; 
      g_tradeState = TRADE_STATE_NONE; 
      SetTimerState(g_tradeState); 
      ShowAlertMessage(3); 
      return;
   }

   double recoveryEntry = g_primaryFibo.slPrice;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int slPoints = g_calculatedSL;
   double recoveryTP = g_isBuySetup ? recoveryEntry - (slPoints * 2.0) * point : recoveryEntry + (slPoints * 2.0) * point;
   double tpCheckPrice = InpUseSpread ? (g_isBuySetup ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID)) 
                                      : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   bool tpHit = (g_isBuySetup && tpCheckPrice <= recoveryTP) || 
                (!g_isBuySetup && tpCheckPrice >= recoveryTP); 
   if(tpHit) {
      g_tradeActive = false; 
      g_tradeState = TRADE_STATE_NONE; 
      SetTimerState(g_tradeState); 
      ShowAlertMessage(2); 
   }
}

//+------------------------------------------------------------------+
//| Helper function to check if a line breakout is already recorded  |
//+------------------------------------------------------------------+
bool IsLineBreakoutProcessed(string lineName)
{
   for(int i = 0; i < ArraySize(g_breakoutHistory); i++) {
      if(g_breakoutHistory[i].lineName == lineName) return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Handle Key Press                                                 |
//+------------------------------------------------------------------+
void HandleKeyPress(int key)
{
   if(key == 72 || key == 104) { // H or h
      g_isHighActive = !g_isHighActive;
      ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, g_isHighActive);
      UpdateButtonState(g_btnHigh, g_isHighActive);
      if(g_isHighActive && g_isLowActive) { g_isLowActive = false; ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, false); UpdateButtonState(g_btnLow, false); }
      ChartRedraw();
   } else if(key == 76 || key == 108) { // L or l
      g_isLowActive = !g_isLowActive;
      ObjectSetInteger(0, g_btnLow, OBJPROP_STATE, g_isLowActive);
      UpdateButtonState(g_btnLow, g_isLowActive);
      if(g_isLowActive && g_isHighActive) { g_isHighActive = false; ObjectSetInteger(0, g_btnHigh, OBJPROP_STATE, false); UpdateButtonState(g_btnHigh, false); }
      ChartRedraw();
   } else if(key == 90 && (TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL) < 0)) { // Ctrl+Z
      PerformUndo();
   }
}

//+------------------------------------------------------------------+
//| Update Fibo Labels to Recovery                                  |
//+------------------------------------------------------------------+
void UpdateFiboLabelsToRecovery(string fiboName, bool isBuy)
{
   ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 0, isBuy ? InpFiboBuyLevel0LabelRecov : InpFiboSellLevel0LabelRecov);
   ObjectSetString(0, fiboName, OBJPROP_LEVELTEXT, 1, isBuy ? InpFiboBuyLevel1LabelRecov : InpFiboSellLevel1LabelRecov);
   color recoveryColor = isBuy ? InpFiboLineColorRecoveryBuy : InpFiboLineColorRecoverySell;
   ObjectSetInteger(0, fiboName, OBJPROP_COLOR, recoveryColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 0, recoveryColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 1, recoveryColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 2, recoveryColor);
   ObjectSetInteger(0, fiboName, OBJPROP_LEVELCOLOR, 3, recoveryColor);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update Timer                                                     |
//+------------------------------------------------------------------+
void UpdateTimer()
{
   if(!InpEnableTimer || !g_tradeActive) {
      if(ObjectFind(0, g_lblTimer) >= 0) {
          ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, "--");
          ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorDefault);
      }
      return;
   }

   int elapsed = (int)(TimeCurrent() - g_tradeActivationTime);
   int remaining = InpTimerDuration - elapsed;
   if(remaining < 0) remaining = 0;
   if(ObjectFind(0, g_lblTimer) < 0) return;
   
   string timerText = StringFormat("%d", remaining);
   ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, timerText);
   ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, remaining > 10 ? InpTimerColorActiveHigh : InpTimerColorActiveLow);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Set Timer State Display                                          |
//+------------------------------------------------------------------+
void SetTimerState(ENUM_TRADE_STATE state)
{
   if(!InpEnableTimer || ObjectFind(0, g_lblTimer) < 0) return;
   switch(state) {
      case TRADE_STATE_NONE:     ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, "--"); ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorDefault); break;
      case TRADE_STATE_BREAKOUT: ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, "--"); ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorArmed); break;
      case TRADE_STATE_ACTIVE:
      case TRADE_STATE_RECOVERY: ObjectSetString(0, g_lblTimer, OBJPROP_TEXT, IntegerToString(InpTimerDuration)); ObjectSetInteger(0, g_lblTimer, OBJPROP_COLOR, InpTimerColorActiveHigh); break;
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Show Motivational Alert and Highlight Reset                      |
//+------------------------------------------------------------------+
void ShowAlertMessage(int type)
{
   if(!InpEnableAlerts) {
      ObjectSetInteger(0, g_btnReset, OBJPROP_BGCOLOR, InpButtonColorActive);
      ChartRedraw();
      return;
   }
   string msg = "";
   switch(type) {
      case 1: msg = InpAlertTextWin; break;
      case 2: msg = InpAlertTextRecov; break;
      case 3: msg = InpAlertTextLoss; break;
   }
   StringReplace(msg, "|", "\n");
   if(msg != "") Alert(msg);
   ObjectSetInteger(0, g_btnReset, OBJPROP_BGCOLOR, InpButtonColorActive);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Helper to remove line from history array                         |
//+------------------------------------------------------------------+
void RemoveLineFromHistory(string lineNameToRemove)
{
   int indexToRemove = -1;
   for(int i = 0; i < g_lineHistoryCount; i++) {
      if(g_lineHistory[i] == lineNameToRemove) { indexToRemove = i; break; }
   }
   if(indexToRemove != -1) {
      for(int i = indexToRemove; i < g_lineHistoryCount - 1; i++) { g_lineHistory[i] = g_lineHistory[i + 1]; }
      g_lineHistoryCount--;
      ArrayResize(g_lineHistory, g_lineHistoryCount);
   }
}

//+------------------------------------------------------------------+
//| Reset Manual Fibo Tracking                                       |
//+------------------------------------------------------------------+
void ResetManualFiboTracking()
{
   g_manualFiboCount_Buy = 0;
   g_manualFiboCount_Sell = 0;
   ArrayResize(g_manualUsedLines_Buy, 0);
   ArrayResize(g_manualUsedLines_Sell, 0);
}

//+------------------------------------------------------------------+
//| Find Next Nearest Line (for Manual Fibo)                         |
//+------------------------------------------------------------------+
string FindNextNearestLine(string lineType, string &usedLines[])
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   LinePrice lines[]; 
   int count = 0;
   for(int i = 0; i < g_lineHistoryCount; i++) {
      string lineName = g_lineHistory[i];
      // Check for both swing and shadow lines of the target type
      if(ObjectFind(0, lineName) < 0 || !( (StringFind(lineName, "_" + lineType + "_") > 0) || (StringFind(lineName, "_SHADOW_" + lineType + "_") > 0) )) continue;
      bool isUsed = false;
      for(int j = 0; j < ArraySize(usedLines); j++) { if(usedLines[j] == lineName) { isUsed = true; break; } }
      if(isUsed) continue;
      ArrayResize(lines, count + 1);
      lines[count].name = lineName;
      lines[count].price = MathAbs(currentPrice - ObjectGetDouble(0, lineName, OBJPROP_PRICE)); // Store distance
      count++;
   }
   if(count == 0) return "";
   // Sort by distance
   for(int i = 0; i < count - 1; i++) {
      for(int j = 0; j < count - i - 1; j++) {
         if(lines[j].price > lines[j + 1].price) { LinePrice temp = lines[j]; lines[j] = lines[j + 1]; lines[j + 1] = temp; }
      }
   }
   return lines[0].name;
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Auto-Detection: Main Function                                    |
//+------------------------------------------------------------------+
void DetectUnmitigatedLevels()
{
   // Remove old auto-detected lines
   for(int obj_idx = ObjectsTotal(0, 0, OBJ_HLINE) - 1; obj_idx >= 0; obj_idx--) {
      string name = ObjectName(0, obj_idx, 0, OBJ_HLINE);
      if(StringFind(name, g_autoLinePrefix) >= 0) {
         ObjectDelete(0, name);
         RemoveLineFromHistory(name);
      }
   }

   int barsAvailable = ArraySize(ExtHighBuffer);
   if(barsAvailable < InpSwingLeftBars + InpSwingRightBars + 2) return;
   int barsToCheck = MathMin(InpLookbackCandles, barsAvailable - InpSwingLeftBars - InpSwingRightBars - 1);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   // Calculate minimum shadow length based on mode
   double min_shadow_price = 0;
   if(InpShadowMode == SHADOW_AUTO)
   {
      // Auto mode: use Stop Loss with multiplier
      int slPoints = g_calculatedSL;
      if(slPoints <= 0)
      {
         // If SL not calculated, fall back to manual value
         min_shadow_price = InpMinShadowPoints * point;
         Print("Shadow Auto Mode: SL not calculated, using manual value: ", InpMinShadowPoints, " points");
      }
      else
      {
         double multiplier = MULTIPLIER_FULL;
         switch(InpShadowMultiplier)
         {
            case SHADOW_1X:      multiplier = MULTIPLIER_FULL;    break;
            case SHADOW_HALF:    multiplier = MULTIPLIER_HALF;    break;
            case SHADOW_THIRD:   multiplier = MULTIPLIER_THIRD;   break;
            case SHADOW_QUARTER: multiplier = MULTIPLIER_QUARTER; break;
         }

         min_shadow_price = (slPoints * multiplier) * point;
         Print("Shadow Auto Mode: SL=", slPoints, " points, Multiplier=", multiplier, ", Min Shadow=", min_shadow_price / point, " points");
      }
   }
   else
   {
      // Manual mode: use custom value
      min_shadow_price = InpMinShadowPoints * point;
      Print("Shadow Manual Mode: Min Shadow=", InpMinShadowPoints, " points");
   }

   // Scan for levels
   for(int i = InpSwingRightBars; i < barsToCheck; i++) 
   {
      bool isSwingLevelDrawn = false; // Flag to prevent duplicate drawing
      datetime swingTime = iTime(_Symbol, _Period, i); // Get time once

      // --- 1. Check Standard Swings (Priority) ---
      if(IsSwingHigh(i)) {
         double swingPrice = ExtHighBuffer[i];
         if(IsUnmitigated(swingPrice, true, i)) {
            bool drawLine = !InpEnableBOSFilter; // Draw if filter disabled
            if(InpEnableBOSFilter) {
               bool bos_confirmed = false; int checkLimit = MathMax(0, i - InpLookbackCandles);
               for(int k = i - 1; k >= checkLimit; k--) {
                  double priorSLPrice = 0; int priorSLBar = -1;
                  if(FindNearestPriorSwingLow(k + 1, InpLookbackCandles, priorSLPrice, priorSLBar)) {
                     if(ExtLowBuffer[k] < priorSLPrice - point) { bos_confirmed = true; break; }
                  }
               } drawLine = bos_confirmed;
            }
            if(drawLine) { DrawAutoLine(swingPrice, swingTime, true, i, "HIGH"); isSwingLevelDrawn = true; }
         }
      } 
      // Check Swing Low only if Swing High wasn't drawn for this bar
      else if(IsSwingLow(i)) { 
         double swingPrice = ExtLowBuffer[i];
         if(IsUnmitigated(swingPrice, false, i)) {
            bool drawLine = !InpEnableBOSFilter; // Draw if filter disabled
             if(InpEnableBOSFilter) {
               bool bos_confirmed = false; int checkLimit = MathMax(0, i - InpLookbackCandles);
               for(int k = i - 1; k >= checkLimit; k--) {
                  double priorSHPrice = 0; int priorSHBar = -1;
                  if(FindNearestPriorSwingHigh(k + 1, InpLookbackCandles, priorSHPrice, priorSHBar)) {
                     if(ExtHighBuffer[k] > priorSHPrice + point) { bos_confirmed = true; break; }
                  }
               } drawLine = bos_confirmed;
            }
            if(drawLine) { DrawAutoLine(swingPrice, swingTime, false, i, "LOW"); isSwingLevelDrawn = true; }
         }
      }

      // --- 2. Check Shadows (Only if Swing not drawn and Shadow Detection Enabled) ---
      if(!isSwingLevelDrawn && InpEnableShadowDetection) 
      {
         double high_i = ExtHighBuffer[i];
         double low_i = ExtLowBuffer[i];
         double open_i = ExtOpenBuffer[i];
         double close_i = ExtCloseBuffer[i];
         double upper_shadow = high_i - MathMax(open_i, close_i);
         double lower_shadow = MathMin(open_i, close_i) - low_i;
         double body_size = MathAbs(open_i - close_i);
         // Define simple pin bar conditions (shadow is long AND opposite shadow is relatively small)
         // We use shadow/2 as a simple threshold for the opposite shadow size. Adjust if needed.
         bool isBearishPin = upper_shadow >= min_shadow_price && lower_shadow < upper_shadow / 2.0; 
         bool isBullishPin = lower_shadow >= min_shadow_price && upper_shadow < lower_shadow / 2.0;
         bool bothShadowsLong = upper_shadow >= min_shadow_price && lower_shadow >= min_shadow_price;

         // Handle based on conditions
         if(isBearishPin) {
             if(IsUnmitigated(high_i, true, i)) {
               bool drawLine = !InpEnableBOSFilter; // Draw if filter disabled
               if(InpEnableBOSFilter) {
                  bool bos_confirmed = false; int checkLimit = MathMax(0, i - InpLookbackCandles);
                  for(int k = i - 1; k >= checkLimit; k--) {
                     double priorSLPrice = 0; int priorSLBar = -1;
                     if(FindNearestPriorSwingLow(k + 1, InpLookbackCandles, priorSLPrice, priorSLBar)) {
                        if(ExtLowBuffer[k] < priorSLPrice - point) { bos_confirmed = true; break; }
                     }
                  } drawLine = bos_confirmed;
               }
               if(drawLine) { DrawAutoLine(high_i, swingTime, true, i, "SHADOW_HIGH"); }
             }
         }
         else if(isBullishPin) {
             if(IsUnmitigated(low_i, false, i)) {
               bool drawLine = !InpEnableBOSFilter; // Draw if filter disabled
               if(InpEnableBOSFilter) {
                  bool bos_confirmed = false; int checkLimit = MathMax(0, i - InpLookbackCandles);
                  for(int k = i - 1; k >= checkLimit; k--) {
                     double priorSHPrice = 0; int priorSHBar = -1;
                     if(FindNearestPriorSwingHigh(k + 1, InpLookbackCandles, priorSHPrice, priorSHBar)) {
                        if(ExtHighBuffer[k] > priorSHPrice + point) { bos_confirmed = true; break; }
                     }
                  } drawLine = bos_confirmed;
               }
               if(drawLine) { DrawAutoLine(low_i, swingTime, false, i, "SHADOW_LOW"); }
             }
         }
         else if(bothShadowsLong && InpLongShadowsHandling != SHADOW_IGNORE) {
            bool drawHigh = false;
            bool drawLow = false;

            if(InpLongShadowsHandling == SHADOW_BOTH) {
               drawHigh = true;
               drawLow = true;
            } else if (InpLongShadowsHandling == SHADOW_LARGER) {
               if(upper_shadow >= lower_shadow) drawHigh = true; // Draw high if upper is larger or equal
               if(lower_shadow >= upper_shadow) drawLow = true;  // Draw low if lower is larger or equal
            }

            // Check and draw High if needed
            if(drawHigh && IsUnmitigated(high_i, true, i)) {
               bool drawLine = !InpEnableBOSFilter;
               if(InpEnableBOSFilter) {
                  bool bos_confirmed = false; int checkLimit = MathMax(0, i - InpLookbackCandles);
                  for(int k = i - 1; k >= checkLimit; k--) {
                     double priorSLPrice = 0; int priorSLBar = -1;
                     if(FindNearestPriorSwingLow(k + 1, InpLookbackCandles, priorSLPrice, priorSLBar)) {
                        if(ExtLowBuffer[k] < priorSLPrice - point) { bos_confirmed = true; break; }
                     }
                  } drawLine = bos_confirmed;
               }
               if(drawLine) { DrawAutoLine(high_i, swingTime, true, i, "SHADOW_HIGH"); }
            }
            // Check and draw Low if needed
            if(drawLow && IsUnmitigated(low_i, false, i)) {
               bool drawLine = !InpEnableBOSFilter;
               if(InpEnableBOSFilter) {
                  bool bos_confirmed = false; int checkLimit = MathMax(0, i - InpLookbackCandles);
                  for(int k = i - 1; k >= checkLimit; k--) {
                     double priorSHPrice = 0; int priorSHBar = -1;
                     if(FindNearestPriorSwingHigh(k + 1, InpLookbackCandles, priorSHPrice, priorSHBar)) {
                        if(ExtHighBuffer[k] > priorSHPrice + point) { bos_confirmed = true; break; }
                     }
                  } drawLine = bos_confirmed;
               }
                if(drawLine) { DrawAutoLine(low_i, swingTime, false, i, "SHADOW_LOW"); }
            }
         }
      } // End Shadow Check
   } // End main loop i

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Helper to Draw Auto-Detected Line (Swing or Shadow)              |
//+------------------------------------------------------------------+
void DrawAutoLine(double price, datetime time, bool isHigh, int barIndex, string type)
{
   string lineName = g_autoLinePrefix + type + "_" + IntegerToString(barIndex); 
   ObjectCreate(0, lineName, OBJ_HLINE, 0, time, price);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, isHigh ? InpHighLineColor : InpLowLineColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, isHigh ? InpHighLineWidth : InpLowLineWidth);
   ObjectSetInteger(0, lineName, OBJPROP_STYLE, isHigh ? InpHighLineStyle : InpLowLineStyle);
   ObjectSetInteger(0, lineName, OBJPROP_BACK, false);
   ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, true);

   // Check if line already exists in history (safety check)
   bool found = false;
   for(int i=0; i < g_lineHistoryCount; i++) { if(g_lineHistory[i] == lineName) {found = true; break;} }
   
   if(!found) {
     ArrayResize(g_lineHistory, g_lineHistoryCount + 1);
     g_lineHistory[g_lineHistoryCount++] = lineName;
   }
}


//+------------------------------------------------------------------+
//| Check if bar is a Swing High                                     |
//+------------------------------------------------------------------+
bool IsSwingHigh(int bar)
{
   int barsAvailable = ArraySize(ExtHighBuffer);
   if(bar < InpSwingRightBars || bar >= barsAvailable - InpSwingLeftBars) return false; 
   double centerHigh = ExtHighBuffer[bar];
   for(int i = 1; i <= InpSwingLeftBars; i++) { if(ExtHighBuffer[bar + i] >= centerHigh) return false; }
   for(int i = 1; i <= InpSwingRightBars; i++) { if(ExtHighBuffer[bar - i] > centerHigh) return false; }
   return true;
}

//+------------------------------------------------------------------+
//| Check if bar is a Swing Low                                      |
//+------------------------------------------------------------------+
bool IsSwingLow(int bar)
{
   int barsAvailable = ArraySize(ExtLowBuffer);
   if(bar < InpSwingRightBars || bar >= barsAvailable - InpSwingLeftBars) return false; 
   double centerLow = ExtLowBuffer[bar];
   for(int i = 1; i <= InpSwingLeftBars; i++) { if(ExtLowBuffer[bar + i] <= centerLow) return false; }
   for(int i = 1; i <= InpSwingRightBars; i++) { if(ExtLowBuffer[bar - i] < centerLow) return false; }
   return true;
}

//+------------------------------------------------------------------+
//| Check if level is still unmitigated (not crossed by price)      |
//+------------------------------------------------------------------+
bool IsUnmitigated(double price, bool isHigh, int fromBar)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int limit = MathMax(0, fromBar - InpLookbackCandles); 
   for(int i = fromBar - 1; i >= limit; i--) {
      if(isHigh && ExtHighBuffer[i] > price + point) return false; 
      if(!isHigh && ExtLowBuffer[i] < price - point) return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Find NEAREST Prior Swing Low before startBar                     |
//+------------------------------------------------------------------+
bool FindNearestPriorSwingLow(int startBar, int maxLookback, double &lowPrice, int &lowBar)
{
   lowPrice = 0; lowBar = -1;
   int barsAvailable = ArraySize(ExtLowBuffer);
   int limit = MathMin(barsAvailable - 1, startBar + maxLookback); 
   for(int i = startBar; i < limit; i++) {
      if(IsSwingLow(i)) {
         lowPrice = ExtLowBuffer[i];
         lowBar = i;
         return true; // Found the NEAREST one
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Find NEAREST Prior Swing High before startBar                    |
//+------------------------------------------------------------------+
bool FindNearestPriorSwingHigh(int startBar, int maxLookback, double &highPrice, int &highBar)
{
   highPrice = 0; highBar = -1;
   int barsAvailable = ArraySize(ExtHighBuffer);
   int limit = MathMin(barsAvailable - 1, startBar + maxLookback); 
   for(int i = startBar; i < limit; i++) {
      if(IsSwingHigh(i)) {
         highPrice = ExtHighBuffer[i];
         highBar = i;
         return true; // Found the NEAREST one
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Merge Nearby Levels - Keep Closest to Current Price             |
//+------------------------------------------------------------------+
void MergeNearbyLevels()
{
   // Calculate proximity based on mode
   double proximity = 0;
   if(InpMergeMode == MERGE_AUTO)
   {
      // Auto mode: use Stop Loss with multiplier
      int slPoints = g_calculatedSL;
      if(slPoints <= 0)
      {
         Alert("Stop Loss not calculated yet! Cannot merge in Auto mode.");
         return;
      }

      double multiplier = MULTIPLIER_FULL;
      switch(InpMergeMultiplier)
      {
         case MERGE_1X:      multiplier = MULTIPLIER_FULL;    break;
         case MERGE_HALF:    multiplier = MULTIPLIER_HALF;    break;
         case MERGE_THIRD:   multiplier = MULTIPLIER_THIRD;   break;
         case MERGE_QUARTER: multiplier = MULTIPLIER_QUARTER; break;
      }

      proximity = (slPoints * multiplier) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      Print("Merge Auto Mode: SL=", slPoints, " points, Multiplier=", multiplier, ", Proximity=", proximity / SymbolInfoDouble(_Symbol, SYMBOL_POINT), " points");
   }
   else
   {
      // Manual mode: use custom proximity
      proximity = InpMergeProximity * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      Print("Merge Manual Mode: Proximity=", InpMergeProximity, " points");
   }

   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   struct LevelInfo { string name; double price; };
   LevelInfo highs[]; LevelInfo lows[];
   int highCount = 0; int lowCount = 0;

   // Collect all FBO lines
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--) {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      if(StringFind(name, "FBO_") != 0) continue; // Only FBO lines
      double price = ObjectGetDouble(0, name, OBJPROP_PRICE);
      if(price > currentPrice) { ArrayResize(highs, highCount + 1); highs[highCount].name = name; highs[highCount].price = price; highCount++; } 
      else { ArrayResize(lows, lowCount + 1); lows[lowCount].name = name; lows[lowCount].price = price; lowCount++; }
   }

   // Merge highs (keep lowest)
   for(int i = 0; i < highCount; i++) {
      if(highs[i].name == "") continue;
      for(int j = i + 1; j < highCount; j++) {
         if(highs[j].name == "") continue;
         if(MathAbs(highs[i].price - highs[j].price) <= proximity) {
            if(highs[i].price > highs[j].price) { ObjectDelete(0, highs[i].name); RemoveLineFromHistory(highs[i].name); highs[i].name = ""; break; } 
            else { ObjectDelete(0, highs[j].name); RemoveLineFromHistory(highs[j].name); highs[j].name = ""; }
         }
      }
   }
   // Merge lows (keep highest)
   for(int i = 0; i < lowCount; i++) {
      if(lows[i].name == "") continue;
      for(int j = i + 1; j < lowCount; j++) {
         if(lows[j].name == "") continue;
         if(MathAbs(lows[i].price - lows[j].price) <= proximity) {
            if(lows[i].price < lows[j].price) { ObjectDelete(0, lows[i].name); RemoveLineFromHistory(lows[i].name); lows[i].name = ""; break; } 
            else { ObjectDelete(0, lows[j].name); RemoveLineFromHistory(lows[j].name); lows[j].name = ""; }
         }
      }
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Push Action to UNDO Stack                                        |
//+------------------------------------------------------------------+
void PushUndoAction(string objType, string objName, double p1, double p2, datetime t1, datetime t2, color c, int w, ENUM_LINE_STYLE s, bool isBuy)
{
   // If stack is full, shift all elements left (remove oldest)
   if(g_undoStackSize >= 10)
   {
      for(int i = 0; i < 9; i++)
      {
         g_undoStack[i] = g_undoStack[i + 1];
      }
      g_undoStackSize = 9;
   }

   // Add new action to stack
   g_undoStack[g_undoStackSize].objectType = objType;
   g_undoStack[g_undoStackSize].objectName = objName;
   g_undoStack[g_undoStackSize].price1 = p1;
   g_undoStack[g_undoStackSize].price2 = p2;
   g_undoStack[g_undoStackSize].time1 = t1;
   g_undoStack[g_undoStackSize].time2 = t2;
   g_undoStack[g_undoStackSize].objColor = c;
   g_undoStack[g_undoStackSize].width = w;
   g_undoStack[g_undoStackSize].style = s;
   g_undoStack[g_undoStackSize].isBuy = isBuy;
   g_undoStackSize++;
}

//+------------------------------------------------------------------+
//| Perform UNDO Operation                                           |
//+------------------------------------------------------------------+
void PerformUndo()
{
   if(g_undoStackSize <= 0)
   {
      Alert("Nothing to undo!");
      return;
   }

   // Pop last action from stack
   g_undoStackSize--;
   UndoAction action = g_undoStack[g_undoStackSize];

   // Delete the object
   if(ObjectFind(0, action.objectName) >= 0)
   {
      ObjectDelete(0, action.objectName);

      // Remove from line history if it's a line
      if(action.objectType == "LINE")
      {
         RemoveLineFromHistory(action.objectName);
      }

      // Remove from manual fibo tracking if it's a fibo
      if(action.objectType == "FIBO")
      {
         if(action.isBuy)
         {
            // Decrement count
            if(g_manualFiboCount_Buy > 0) g_manualFiboCount_Buy--;

            // Remove from used lines array
            int size = ArraySize(g_manualUsedLines_Buy);
            if(size > 0)
            {
               ArrayResize(g_manualUsedLines_Buy, size - 1);
            }
         }
         else
         {
            // Decrement count
            if(g_manualFiboCount_Sell > 0) g_manualFiboCount_Sell--;

            // Remove from used lines array
            int size = ArraySize(g_manualUsedLines_Sell);
            if(size > 0)
            {
               ArrayResize(g_manualUsedLines_Sell, size - 1);
            }
         }
      }

      ChartRedraw();
      Print("Undo: Removed ", action.objectType, " - ", action.objectName);
   }
   else
   {
      Print("Undo: Object ", action.objectName, " not found!");
   }
}

//+------------------------------------------------------------------+
//| Toggle Focus Mode                                                |
//+------------------------------------------------------------------+
void ToggleFocusMode()
{
   if(g_isFocusActive)
   {
      DeactivateFocusMode();
   }
   else
   {
      string nearestLine = FindNearestLineToPrice();
      if(nearestLine == "")
      {
         Alert("No lines found to focus on!");
         return;
      }
      ActivateFocusMode(nearestLine);
   }
}

//+------------------------------------------------------------------+
//| Find Nearest Line to Current Price                               |
//+------------------------------------------------------------------+
string FindNearestLineToPrice()
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double minDistance = 1e100;
   string nearestLine = "";

   // Check all manual lines
   for(int i = 0; i < g_lineHistoryCount; i++)
   {
      string lineName = g_lineHistory[i];
      if(ObjectFind(0, lineName) < 0) continue;

      double linePrice = ObjectGetDouble(0, lineName, OBJPROP_PRICE);
      double distance = MathAbs(currentPrice - linePrice);

      if(distance < minDistance)
      {
         minDistance = distance;
         nearestLine = lineName;
      }
   }

   // Also check auto-detected lines
   for(int obj_idx = 0; obj_idx < ObjectsTotal(0, 0, OBJ_HLINE); obj_idx++)
   {
      string name = ObjectName(0, obj_idx, 0, OBJ_HLINE);
      if(StringFind(name, g_autoLinePrefix) >= 0)
      {
         double linePrice = ObjectGetDouble(0, name, OBJPROP_PRICE);
         double distance = MathAbs(currentPrice - linePrice);

         if(distance < minDistance)
         {
            minDistance = distance;
            nearestLine = name;
         }
      }
   }

   return nearestLine;
}

//+------------------------------------------------------------------+
//| Activate Focus Mode                                              |
//+------------------------------------------------------------------+
void ActivateFocusMode(string nearestLine)
{
   g_isFocusActive = true;
   g_focusedLine = nearestLine;
   g_focusedFibo = "";
   g_focusedBox = "";

   // Find associated fibo and box
   double linePrice = ObjectGetDouble(0, nearestLine, OBJPROP_PRICE);

   // Find fibo that is drawn ON this specific line (fibo center = line price)
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double minCenterDistance = 1e100;
   for(int i = 0; i < ObjectsTotal(0, 0, OBJ_FIBO); i++)
   {
      string fiboName = ObjectName(0, i, 0, OBJ_FIBO);
      double fibo_price1 = ObjectGetDouble(0, fiboName, OBJPROP_PRICE, 0);
      double fibo_price2 = ObjectGetDouble(0, fiboName, OBJPROP_PRICE, 1);
      double fibo_center = (fibo_price1 + fibo_price2) / 2.0;
      double centerDistance = MathAbs(fibo_center - linePrice);

      if(centerDistance < FOCUS_CENTER_DISTANCE_POINTS * point && centerDistance < minCenterDistance)
      {
         g_focusedFibo = fiboName;
         minCenterDistance = centerDistance;
      }
   }

   // Find box (highlight) near this line
   for(int i = 0; i < ObjectsTotal(0, 0, OBJ_RECTANGLE); i++)
   {
      string boxName = ObjectName(0, i, 0, OBJ_RECTANGLE);
      if(StringFind(boxName, g_boxPrefix) >= 0)
      {
         double box_price1 = ObjectGetDouble(0, boxName, OBJPROP_PRICE, 0);
         double box_price2 = ObjectGetDouble(0, boxName, OBJPROP_PRICE, 1);

         if((linePrice >= box_price1 && linePrice <= box_price2) ||
            (linePrice >= box_price2 && linePrice <= box_price1))
         {
            g_focusedBox = boxName;
            break;
         }
      }
   }

   // Save original states and dim all objects except focused ones
   ArrayResize(g_savedStates, 0);
   g_savedStatesCount = 0;

   // Dim all lines
   for(int i = 0; i < ObjectsTotal(0, 0, OBJ_HLINE); i++)
   {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      if(name != nearestLine)
      {
         ArrayResize(g_savedStates, g_savedStatesCount + 1);
         g_savedStates[g_savedStatesCount].name = name;
         g_savedStates[g_savedStatesCount].originalColor = (color)ObjectGetInteger(0, name, OBJPROP_COLOR);
         g_savedStates[g_savedStatesCount].originalWidth = (int)ObjectGetInteger(0, name, OBJPROP_WIDTH);
         g_savedStates[g_savedStatesCount].originalStyle = (ENUM_LINE_STYLE)ObjectGetInteger(0, name, OBJPROP_STYLE);
         g_savedStatesCount++;

         ObjectSetInteger(0, name, OBJPROP_COLOR, InpFocusDimmedColor);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, InpFocusDimmedWidth);
      }
   }

   // Dim all fibos except focused
   for(int i = 0; i < ObjectsTotal(0, 0, OBJ_FIBO); i++)
   {
      string name = ObjectName(0, i, 0, OBJ_FIBO);
      if(name != g_focusedFibo)
      {
         ArrayResize(g_savedStates, g_savedStatesCount + 1);
         g_savedStates[g_savedStatesCount].name = name;
         g_savedStates[g_savedStatesCount].originalColor = (color)ObjectGetInteger(0, name, OBJPROP_COLOR);
         g_savedStates[g_savedStatesCount].originalWidth = (int)ObjectGetInteger(0, name, OBJPROP_WIDTH);
         g_savedStates[g_savedStatesCount].originalStyle = (ENUM_LINE_STYLE)ObjectGetInteger(0, name, OBJPROP_STYLE);
         g_savedStatesCount++;

         ObjectSetInteger(0, name, OBJPROP_COLOR, InpFocusDimmedColor);
         int levelCount = (int)ObjectGetInteger(0, name, OBJPROP_LEVELS);
         for(int lv = 0; lv < levelCount; lv++)
         {
            ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, lv, InpFocusDimmedColor);
         }
      }
   }

   // Dim all boxes except focused
   for(int i = 0; i < ObjectsTotal(0, 0, OBJ_RECTANGLE); i++)
   {
      string name = ObjectName(0, i, 0, OBJ_RECTANGLE);
      if(StringFind(name, g_boxPrefix) >= 0 && name != g_focusedBox)
      {
         ArrayResize(g_savedStates, g_savedStatesCount + 1);
         g_savedStates[g_savedStatesCount].name = name;
         g_savedStates[g_savedStatesCount].originalColor = (color)ObjectGetInteger(0, name, OBJPROP_COLOR);
         g_savedStatesCount++;

         ObjectSetInteger(0, name, OBJPROP_COLOR, InpFocusDimmedBoxColor);
      }
   }

   if(nearestLine != "" && ObjectFind(0, nearestLine) >= 0)
   {
      g_focusedLineOriginalWidth = (int)ObjectGetInteger(0, nearestLine, OBJPROP_WIDTH);
      ObjectSetInteger(0, nearestLine, OBJPROP_WIDTH, InpFocusedWidth);
   }

   if(g_focusedFibo != "" && ObjectFind(0, g_focusedFibo) >= 0)
   {
      int levelCount = (int)ObjectGetInteger(0, g_focusedFibo, OBJPROP_LEVELS);
      ArrayResize(g_focusedFiboOriginalLevelWidths, levelCount);

      for(int lv = 0; lv < levelCount; lv++)
      {
         g_focusedFiboOriginalLevelWidths[lv] = (int)ObjectGetInteger(0, g_focusedFibo, OBJPROP_LEVELWIDTH, lv);
         ObjectSetInteger(0, g_focusedFibo, OBJPROP_LEVELWIDTH, lv, InpFocusedWidth);
      }
   }

   UpdateButtonState(g_btnFocus, true);
   ObjectSetInteger(0, g_btnFocus, OBJPROP_STATE, true);

   ChartRedraw();
   Print("Focus Mode Activated on: ", nearestLine);
}

//+------------------------------------------------------------------+
//| Deactivate Focus Mode                                            |
//+------------------------------------------------------------------+
void DeactivateFocusMode()
{
   g_isFocusActive = false;

   if(g_focusedLine != "" && ObjectFind(0, g_focusedLine) >= 0)
   {
      ObjectSetInteger(0, g_focusedLine, OBJPROP_WIDTH, g_focusedLineOriginalWidth);
   }

   if(g_focusedFibo != "" && ObjectFind(0, g_focusedFibo) >= 0)
   {
      int savedLevelCount = ArraySize(g_focusedFiboOriginalLevelWidths);
      for(int lv = 0; lv < savedLevelCount; lv++)
      {
         ObjectSetInteger(0, g_focusedFibo, OBJPROP_LEVELWIDTH, lv, g_focusedFiboOriginalLevelWidths[lv]);
      }
   }

   for(int i = 0; i < g_savedStatesCount; i++)
   {
      string name = g_savedStates[i].name;
      if(ObjectFind(0, name) >= 0)
      {
         ENUM_OBJECT objType = (ENUM_OBJECT)ObjectGetInteger(0, name, OBJPROP_TYPE);

         if(objType == OBJ_HLINE)
         {
            ObjectSetInteger(0, name, OBJPROP_COLOR, g_savedStates[i].originalColor);
            ObjectSetInteger(0, name, OBJPROP_WIDTH, g_savedStates[i].originalWidth);
            ObjectSetInteger(0, name, OBJPROP_STYLE, g_savedStates[i].originalStyle);
         }
         else if(objType == OBJ_FIBO)
         {
            ObjectSetInteger(0, name, OBJPROP_COLOR, g_savedStates[i].originalColor);
            ObjectSetInteger(0, name, OBJPROP_WIDTH, g_savedStates[i].originalWidth);
            ObjectSetInteger(0, name, OBJPROP_STYLE, g_savedStates[i].originalStyle);
            int levelCount = (int)ObjectGetInteger(0, name, OBJPROP_LEVELS);
            for(int lv = 0; lv < levelCount; lv++)
            {
               ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, lv, g_savedStates[i].originalColor);
            }
         }
         else if(objType == OBJ_RECTANGLE)
         {
            ObjectSetInteger(0, name, OBJPROP_COLOR, g_savedStates[i].originalColor);
         }
      }
   }

   ArrayResize(g_savedStates, 0);
   g_savedStatesCount = 0;
   ArrayResize(g_focusedFiboOriginalLevelWidths, 0);

   g_focusedLine = "";
   g_focusedFibo = "";
   g_focusedBox = "";
   g_focusedLineOriginalWidth = 0;

   UpdateButtonState(g_btnFocus, false);
   ObjectSetInteger(0, g_btnFocus, OBJPROP_STATE, false);

   ChartRedraw();
   Print("Focus Mode Deactivated");
}
//+------------------------------------------------------------------+