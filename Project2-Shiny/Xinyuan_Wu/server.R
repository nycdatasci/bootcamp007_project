library(googleVis)
library(reshape2)
library(shiny)
library(DT)

function(input, output) {
    plot14 <- reactive({
        data %>% filter(carline_broad == input$type)
    })
    plot2 <- reactive({
        data %>% filter(carline_broad == input$type) %>% 
            group_by(fuel_type) %>% summarize(count = n())
    })
    plot3 <- reactive({
        data %>% filter(carline_broad == input$type) %>%
            group_by(drive_desc) %>% summarize(count = n())
    })
    plot5 <- reactive({
        data5 <- data %>% filter(make == input$manuf) %>%
            group_by(carline_broad, year) %>%
            summarize(citympg = mean(mpg_mix),
                      hwympg = mean(mpg_hwy), mixmpg = mean(mpg_mix)) %>%
            as.data.frame()
        data5$carline_broad <- factor(data5$carline_broad)
        data5
    })
    plot6 <- reactive({
        data6 <- data %>% filter(make == input$manuf) %>%
            group_by(year, carline_broad) %>% summarize(mpg = mean(mpg_mix))
        dcast(data6, year ~ carline_broad, value.var = 'mpg')
        
    })
    table1 <- reactive({
        temp <- data %>% filter(condition == input$condition, carline_broad == input$carline,
                                lux == input$lux, trans_broad == input$trans) %>% as.data.frame()
        temp <- temp %>% 
            select(year:model, cyl:trans_desc, drive_desc, fuel_type, mpg_mix, ann_fuel) %>%
            rename(Year = year, Make = make, Model = model, Cylinder = cyl, Displacement = disp,
                   AirAspiration = air_asp, Transmission = trans_desc, Drive = drive_desc, 
                   Fuel = fuel_type, OverallMPG = mpg_mix, AnnualFuelCost = ann_fuel) %>% as.data.frame()
        temp
    })
    # observe({
    #     print(input$type)
    # })
    output$plot1 <- renderPlot({
        g <- ggplot(plot14(), aes_string(x = 'trans_desc', y = input$mpgtype))
        g <- g + geom_boxplot(aes(color = trans_desc))
        g <- g + xlab("Transmission Type") + ylab("Selected Parameter") + ggtitle("Fuel Consumption vs. Transmission")
        # g <- g + theme_gdocs()
        g <- g + coord_cartesian(ylim = c(5, 60))
        g <- g + theme(legend.position="none")
        g <- g + scale_colour_hue("Transmission Type")
        g
    })
    output$plot2 <- renderPlot({
        g <- ggplot(plot2(), aes(x = fuel_type, y = count))
        g <- g + geom_bar(stat = 'identity', aes(fill = fuel_type))
        g <- g + xlab("Fuel Type") + ylab("Count") + ggtitle("Vehicle Distribution vs. fuel type")
        # g <- g + theme_gdocs()
        g <- g + theme(legend.position="none")
        g
    })
    output$plot3 <- renderPlot({
        g <- ggplot(plot3(), aes(x = drive_desc, y = count))
        g <- g + geom_bar(stat = 'identity', aes(fill = drive_desc))
        g <- g + xlab("Drive Type") + ylab("Count") + ggtitle("Vehicle Distribution vs. Drive Type")
        # g <- g + theme_gdocs()
        g <- g + theme(legend.position="none")
        g
    })
    output$plot4 <- renderPlot({
        g <- ggplot(plot14(), aes_string(x = 'disp', y = input$mpgtype))
        g <- g + geom_point(position = 'jitter', alpha = 0.2)
        g <- g + geom_smooth(aes(color = disp), size = 2, se = FALSE, color = "orange")
        g <- g + xlab("Displacement") + ylab("Selected Parameter") + ggtitle("Fuel Consumption vs. Displacement")
        g <- g + coord_cartesian(ylim = c(5, 60))
        # g <- g + theme_gdocs()
        g <- g + theme(legend.position="none")
        g <- g + scale_colour_hue("Displacement")
        g
        
    })
    output$plot5 <- renderGvis({
      print("test")
        gvisMotionChart(plot5(), idvar = "carline_broad", timevar = "year",
                        options=list(width = 1000,
                                     height = 600))
    })
    
    # output$plot6 <- renderGvis({
    #     gvisColumnChart(plot6(),
    #                  options=list(fontSize = 16,
    #                               title = "Average MPG vs. Vehicle Type",
    #                               hAxis = "{title : 'Miles-Per-Galon'}",
    #                               vAxis = "{title : 'Year'}",
    #                               legend = "{position:'none'}",
    #                               height = 400))
    # })

    output$ui <- renderUI({
        if (dim(table1())[1] == 0) {
            return('no range can be generated')
        }
        ann_range <- range(table1()$AnnualFuelCost)
        sliderInput("fuel_range", "Select annual fuel cost (dollars)", min = ann_range[1],
                    max = ann_range[2], value = ann_range[2])
    })
    output$table_output <- DT::renderDataTable({
        if (is.null(input$fuel_range)) {
            return()
        }
        table2 <- table1() %>% filter(AnnualFuelCost <= input$fuel_range) %>% as.data.frame()
        datatable(table2, rownames = FALSE) %>%
            formatStyle('AnnualFuelCost', background = "skyblue", fontWeight = 'bold')
    })
        
        
        
        
        
        
}