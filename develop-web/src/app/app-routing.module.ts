import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { MangaTableComponent } from './pages/manga-table/manga-table.component';
import { CategoriesTableComponent } from './pages/categories-table/categories-table.component';
import { UserTableComponent } from './pages/users-table/users-table.component';
import { LoginComponent } from './pages/login/login.component';
import { RegisterComponent } from './pages/register/register.component';
import { ProfileComponent } from './pages/profile/profile.component';
import { MangaDetailComponent } from './pages/manga-detail/manga-detail.component';
import { AuthGuard } from './guards/auth.guard';
import { LoginGuard } from './guards/login.guard';
import { UnsaveGuard } from './guards/unsave.guard';
import { PurchaseTableComponent } from './pages/purchase-table/purchase-table.component';


const routes: Routes = [
  {path:'manga', component:MangaTableComponent, pathMatch: 'full', canActivate:[LoginGuard]},
  {path:'categories', component:CategoriesTableComponent, pathMatch: 'full', canActivate:[AuthGuard]},
  {path:'users', component:UserTableComponent, pathMatch: 'full', canActivate:[AuthGuard]},

 // {path:'reports', component:ReportTableComponent, pathMatch: 'full', canActivate:[AuthGuard]},
  {path:'login', component:LoginComponent, pathMatch: 'full'},
  {path:'register', component:RegisterComponent, pathMatch: 'full'},
  {path:'profile', component:ProfileComponent, pathMatch: 'full', canActivate:[AuthGuard], canDeactivate:[UnsaveGuard]},
  {path:'manga/detail/:idManga', component: MangaDetailComponent, pathMatch: 'full', canActivate:[AuthGuard]},
  {path:'purchase',component: PurchaseTableComponent, pathMatch: 'full', canActivate:[AuthGuard]},
  {path:'', pathMatch: 'full', redirectTo:'login'}
];


@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
