//
//  ViewController.m
//  picker
//
//  Created by Sylar on 12-9-14.
//  Copyright (c) 2012年 Sylar. All rights reserved.
//

#import "ViewController.h"
#import "AddressFMDBManager.h"
#import "ProvinceAddressModel.h"
#import "CityAddressModel.h"
#import "DistrictModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    province=[[NSMutableArray alloc] initWithCapacity:5];
    city=[[NSMutableArray alloc] initWithCapacity:5];
    district=[[NSMutableArray alloc] initWithCapacity:5];
    
    AddressFMDBManager *addFMDBManager=[AddressFMDBManager sharedAddressFMDBManager];

    //得到省份的model数组
    NSArray *arr=[NSArray arrayWithArray:[addFMDBManager selectAllProvince]];
    for (ProvinceAddressModel *provinceModel in arr) {
        [province addObject:provinceModel.name];
    }
    NSLog(@"%@",province);
    
    //得到市的model的数组     
    NSArray *arr2=[NSArray arrayWithArray:[addFMDBManager selectAllCityFrom:1]];

    for (CityAddressModel *cityModel in arr2) {
        [city addObject:cityModel.name];
    }
     NSLog(@"%@",city);
    
    //得到区的model的数组
    NSArray *arr3=[NSArray arrayWithArray:[addFMDBManager selectAllDistrictFrom:1]];
    for (DistrictModel *districtModel in arr3) {
        [district addObject:districtModel.name];
    }
     NSLog(@"%@",district);
    
    
    picker = [[UIPickerView alloc] initWithFrame: CGRectMake(0, 0, 320, 240)];
    picker.dataSource = self;
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    [picker selectRow: 0 inComponent: 0 animated: YES];
    [self.view addSubview: picker];
    
   selectedProvince = [province objectAtIndex: 0];
    
    button = [UIButton buttonWithType: 100];
    [button setTitle: @"测试PickerView效果" forState: UIControlStateNormal];
    [button setFrame: CGRectMake(160-button.bounds.size.width/2, 320, button.bounds.size.width, button.bounds.size.height)];
    [button setTintColor: [UIColor grayColor]];
    [button addTarget: self action: @selector(buttobClicked:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: button];
     
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark- button clicked

- (void) buttobClicked:(id)sender {
    NSInteger provinceIndex = [picker selectedRowInComponent: PROVINCE_COMPONENT];
    NSInteger cityIndex = [picker selectedRowInComponent: CITY_COMPONENT];
    NSInteger districtIndex = [picker selectedRowInComponent: DISTRICT_COMPONENT];
    
    NSString *provinceStr = [province objectAtIndex: provinceIndex];
    NSString *cityStr = [city objectAtIndex: cityIndex];
    NSString *districtStr = [district objectAtIndex:districtIndex];
    
    if ([provinceStr isEqualToString: cityStr] && [cityStr isEqualToString: districtStr]) {
        cityStr = @"";
        districtStr = @"";
    }
    else if ([cityStr isEqualToString: districtStr]) {
        districtStr = @"";
    }
    
    NSString *showMsg = [NSString stringWithFormat: @"%@ %@ %@.", provinceStr, cityStr, districtStr];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"alert"
                                              message: showMsg
                                              delegate: self
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles: nil, nil];
    
    [alert show];

    
}



#pragma mark- Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        return [province count];
    }
    else if (component == CITY_COMPONENT) {
        return [city count];
    }
    else {
        return [district count];
    }
}


#pragma mark- Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        return [province objectAtIndex: row];
    }
    else if (component == CITY_COMPONENT) {
        return [city objectAtIndex: row];
    }
    else {
        return [district objectAtIndex: row];
    }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == PROVINCE_COMPONENT) {
        selectedProvince = [province objectAtIndex: row];
        
        AddressFMDBManager *addFMDBManager=[AddressFMDBManager sharedAddressFMDBManager];

        [city removeAllObjects];
        //得到市的model的数组
        NSArray *arr2=[NSArray arrayWithArray:[addFMDBManager selectAllCityFrom:row+1]];
        for (CityAddressModel *cityModel in arr2) {
            [city addObject:cityModel.name];
        }
        
        //获取城市id
        NSInteger cityId=[addFMDBManager selectIdFromCityWith:[city objectAtIndex:0]];
        
        NSLog(@"城市id为:::%ld",(long)cityId);
        [district removeAllObjects];
        //得到区的model的数组
        NSArray *arr3=[NSArray arrayWithArray:[addFMDBManager selectAllDistrictFrom:cityId]];
        for (DistrictModel *districtModel in arr3) {
            [district addObject:districtModel.name];
        }
 
        [picker selectRow: 0 inComponent: CITY_COMPONENT animated: YES];
        [picker selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
        [picker reloadComponent: CITY_COMPONENT];
        [picker reloadComponent: DISTRICT_COMPONENT];
//        [picker reloadAllComponents];
        
    }
    else if (component == CITY_COMPONENT) {
//        NSInteger *provinceIndex = [province indexOfObject: selectedProvince];
        AddressFMDBManager *addFMDBManager=[AddressFMDBManager sharedAddressFMDBManager];
        NSString *cityName=[city objectAtIndex:row];
        NSInteger cityId=[addFMDBManager selectIdFromCityWith:cityName];
        NSLog(@"====%@",cityName);
        [district removeAllObjects];
        //得到区的model的数组
        NSArray *arr3=[NSArray arrayWithArray:[addFMDBManager selectAllDistrictFrom:cityId]];
        for (DistrictModel *districtModel in arr3) {
            [district addObject:districtModel.name];
        }
        [picker selectRow: 0 inComponent: DISTRICT_COMPONENT animated: YES];
        [picker reloadComponent: DISTRICT_COMPONENT];
    }

}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == PROVINCE_COMPONENT) {
        return 80;
//        return 100;
    }
    else if (component == CITY_COMPONENT) {
        return 120;
    }
    else {
        return 120;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *myView = nil;
    
    if (component == PROVINCE_COMPONENT) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 30)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.text = [province objectAtIndex:row];
        myView.font = [UIFont systemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];
    }
    else if (component == CITY_COMPONENT) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 120, 30)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.text = [city objectAtIndex:row];
        myView.font = [UIFont systemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];
    }
    else {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 120, 30)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.text = [district objectAtIndex:row];
        myView.font = [UIFont systemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];
    }
    
    return myView;
}




@end
