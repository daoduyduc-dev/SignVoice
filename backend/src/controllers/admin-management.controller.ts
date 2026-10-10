import { Request, Response, NextFunction } from 'express';
import { User, AccountType, UserRole } from '../models/User.model';
import { Role } from '../models/Role.model';
import { builtInPermissions, roleForPermissions, assertCanGrant } from '../services/authorization.service';
import { UserSettings } from '../models/UserSettings.model';
import { Category } from '../models/Category.model';
import { DictionaryEntry, EntryStatus } from '../models/DictionaryEntry.model';
import { Favorite } from '../models/Favorite.model';
import { SearchHistory } from '../models/SearchHistory.model';
import { hashPassword } from '../utils/password.util';
import { AppError } from '../common/errors/AppError';
import { ErrorCodes } from '../common/errors/errorCodes';

function paging(req: Request) {
  const page = Number(req.query.page || 1), limit = Number(req.query.limit || 20);
  return {page,limit,skip:(page-1)*limit};
}
function literalSearch(value: unknown): string {
  return String(value || '').replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
function notFound() { return new AppError('Không tìm thấy dữ liệu.',404,ErrorCodes.NOT_FOUND); }
async function syncCategoryCount(id: unknown): Promise<void> {
  const wordCount = await DictionaryEntry.countDocuments({categoryId:id,status:EntryStatus.PUBLISHED});
  await Category.findByIdAndUpdate(id,{$set:{wordCount}});
}

export async function createUser(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const {email,password,displayName,role} = req.body;
    if(await User.exists({email})) throw new AppError('Email đã được sử dụng.',409,ErrorCodes.AUTH_EMAIL_ALREADY_EXISTS);
    const custom=req.body.customRoleId?await Role.findById(req.body.customRoleId):null;
    if(req.body.customRoleId && !custom) throw notFound();
    assertCanGrant(req.user!.permissions,custom?custom.permissions:builtInPermissions[role as UserRole]);
    const user = await User.create({email,displayName,role:custom?roleForPermissions(custom.permissions):role,customRoleId:custom?custom._id:undefined,passwordHash:await hashPassword(password),accountType:AccountType.LOCAL,isGuest:false});
    await UserSettings.create({userId:user._id});
    const safeUser = await User.findById(user._id);
    res.status(201).json({success:true,data:safeUser});
  } catch(error) {next(error);}
}

export async function listRoles(_req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const system=Object.values(UserRole).map(key=>({_id:key,key,name:key,description:'Vai trò hệ thống',permissions:builtInPermissions[key],system:true}));
    const custom=await Role.find().sort({name:1});
    res.json({success:true,data:[...system,...custom.map(role=>({...role.toObject(),system:false}))]});
  } catch(error) {next(error);}
}
export async function userRoleOptions(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const system=Object.values(UserRole).map(key=>({_id:key,key,name:key,permissions:builtInPermissions[key],system:true}));
    const custom=(await Role.find().sort({name:1})).map(role=>({...role.toObject(),system:false}));
    const options=[...system,...custom].filter(role=>role.permissions.every(permission=>req.user!.permissions.includes(permission)));
    res.json({success:true,data:options});
  } catch(error) {next(error);}
}
export async function createRole(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    assertCanGrant(req.user!.permissions,req.body.permissions);
    res.status(201).json({success:true,data:await Role.create(req.body)});
  } catch(error) {next(error);}
}
export async function updateRole(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const existing=await Role.findById(req.params.id);
    if(!existing) throw notFound();
    assertCanGrant(req.user!.permissions,existing.permissions);
    if(req.body.permissions) assertCanGrant(req.user!.permissions,req.body.permissions);
    if(req.user!.customRoleId===req.params.id && req.body.permissions &&
       ['admin:access','roles:write'].some(permission=>!req.body.permissions.includes(permission))) {
      throw new AppError('Không thể bỏ quyền truy cập/quản lý role của chính mình.',400,ErrorCodes.VALIDATION_ERROR);
    }
    const role=await Role.findByIdAndUpdate(req.params.id,{$set:req.body},{new:true,runValidators:true});
    if(!role) throw notFound();
    res.json({success:true,data:role});
  } catch(error) {next(error);}
}
export async function deleteRole(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const existing=await Role.findById(req.params.id);
    if(!existing) throw notFound();
    assertCanGrant(req.user!.permissions,existing.permissions);
    if(await User.exists({customRoleId:req.params.id})) throw new AppError('Role đang được gán cho tài khoản. Hãy đổi role của các tài khoản này trước.',409,ErrorCodes.CONFLICT);
    const role=await Role.findByIdAndDelete(req.params.id);
    if(!role) throw notFound();
    res.json({success:true,data:{message:'Đã xóa role.'}});
  } catch(error) {next(error);}
}

export async function listDictionary(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const {page,limit,skip}=paging(req);
    const filter: Record<string,unknown> = {};
    if(req.query.status) filter.status=req.query.status;
    if(req.query.search) filter.word={$regex:literalSearch(req.query.search),$options:'i'};
    const [items,total]=await Promise.all([
      DictionaryEntry.find(filter).populate('categoryId','name slug').sort({updatedAt:-1}).skip(skip).limit(limit),
      DictionaryEntry.countDocuments(filter),
    ]);
    res.json({success:true,data:{items,pagination:{page,limit,total,pages:Math.ceil(total/limit)}}});
  } catch(error) {next(error);}
}

export async function createDictionary(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const category=await Category.findById(req.body.categoryId);
    if(!category?.isActive()) throw new AppError('Danh mục không tồn tại hoặc đã lưu trữ.',400,ErrorCodes.CATEGORY_NOT_FOUND);
    const status=req.body.status || EntryStatus.DRAFT;
    if(status===EntryStatus.PUBLISHED && !req.user!.permissions.includes('content:publish')) throw new AppError('Bạn không có quyền xuất bản.',403,ErrorCodes.AUTH_FORBIDDEN);
    const entry=await DictionaryEntry.create({...req.body,status,createdBy:req.user!.id,lastModifiedBy:req.user!.id,...(status===EntryStatus.PUBLISHED?{publishedAt:new Date()}:{})});
    await syncCategoryCount(entry.categoryId);
    res.status(201).json({success:true,data:entry});
  } catch(error) {next(error);}
}

export async function updateDictionary(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const entry=await DictionaryEntry.findById(req.params.id);
    if(!entry) throw notFound();
    const oldCategory=entry.categoryId;
    if((entry.status===EntryStatus.PUBLISHED || req.body.status===EntryStatus.PUBLISHED) && !req.user!.permissions.includes('content:publish')) throw new AppError('Bạn không có quyền sửa nội dung đã xuất bản.',403,ErrorCodes.AUTH_FORBIDDEN);
    const category=await Category.findById(req.body.categoryId || entry.categoryId);
    if(!category?.isActive() && (req.body.categoryId || req.body.status===EntryStatus.PUBLISHED)) throw new AppError('Cần chọn danh mục đang hoạt động.',400,ErrorCodes.CATEGORY_NOT_FOUND);
    if(req.body.status===EntryStatus.PUBLISHED && entry.status!==EntryStatus.PUBLISHED) entry.publishedAt=new Date();
    Object.assign(entry,req.body,{lastModifiedBy:req.user!.id});
    await entry.save();
    await syncCategoryCount(oldCategory);
    if(!entry.categoryId.equals(oldCategory)) await syncCategoryCount(entry.categoryId);
    res.json({success:true,data:entry});
  } catch(error) {next(error);}
}

export async function deleteDictionary(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const existing=await DictionaryEntry.findById(req.params.id);
    if(!existing) throw notFound();
    if(existing.status===EntryStatus.PUBLISHED && !req.user!.permissions.includes('content:publish')) throw new AppError('Bạn không có quyền xóa nội dung đã xuất bản.',403,ErrorCodes.AUTH_FORBIDDEN);
    const entry=await DictionaryEntry.findByIdAndDelete(req.params.id);
    if(!entry) throw notFound();
    await Promise.all([
      Favorite.deleteMany({entryId:entry._id}), SearchHistory.deleteMany({entryId:entry._id}),
      DictionaryEntry.updateMany({'relatedWords.entryId':entry._id},{$pull:{relatedWords:{entryId:entry._id}}}),
      syncCategoryCount(entry.categoryId),
    ]);
    res.json({success:true,data:{message:'Đã xóa mục từ điển.'}});
  } catch(error) {next(error);}
}

export async function listCategories(_req: Request, res: Response, next: NextFunction): Promise<void> {
  try {res.json({success:true,data:await Category.find().sort({sortOrder:1,name:1})});} catch(error) {next(error);}
}
export async function createCategory(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {res.status(201).json({success:true,data:await Category.create(req.body)});} catch(error) {next(error);}
}
export async function updateCategory(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const category=await Category.findByIdAndUpdate(req.params.id,{$set:req.body},{new:true,runValidators:true});
    if(!category) throw notFound();
    res.json({success:true,data:category});
  } catch(error) {next(error);}
}
export async function deleteCategory(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if(await DictionaryEntry.exists({categoryId:req.params.id}) || await Category.exists({parentId:req.params.id})) throw new AppError('Danh mục đang được sử dụng. Hãy chuyển hoặc xóa các mục bên trong trước.',409,ErrorCodes.CATEGORY_IN_USE);
    const category=await Category.findByIdAndDelete(req.params.id);
    if(!category) throw notFound();
    res.json({success:true,data:{message:'Đã xóa danh mục.'}});
  } catch(error) {next(error);}
}
